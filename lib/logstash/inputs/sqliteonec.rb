# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "socket"
require "stud/interval"
require "concurrent"
require "time"
require "date"

class LogStash::Inputs::SqliteOnec < LogStash::Inputs::Base
  config_name "sqliteonec"

  # The path to the sqlite database file.
  # we dont need path to db
  # config :path, :validate => :string, :required => true
  default :codec, "plain"

  # Any tables to exclude by name.
  # By default all tables are followed.
  config :exclude_tables, :validate => :array, :default => []

  # How many rows to fetch at a time from each `SELECT` call.
  config :batch, :validate => :number, :default => 5
  config :path_since, :validate => :string, :required => true

  config :onec_base_name, :validate => :string, :required => true
  config :onec_base_guid, :validate => :string, :required => true
  config :onec_server_reg_path, :validate => :string, :required => true

  SINCE_TABLE = :path_since

  public
  def init_placeholder_table(db)
    begin
      @logger.info("create the since table")
      db.create_table SINCE_TABLE do 
        String :table
        INTEGER :place
      end
    rescue
      @logger.info("since tables already exists")
    end
  end

  public
  def get_placeholder(db, table)
    since = db[SINCE_TABLE]
    x = since.where(:table => "#{table}")
    if x[:place].nil?
      init_placeholder(db, table) 
      return 0
    else
      @logger.info("placeholder already exists, it is #{x[:place]}")
      return x[:place][:place]
    end
  end

  public 
  def init_placeholder(db, table)
    @logger.info("init placeholder for #{table}")
    since = db[SINCE_TABLE]
    since.insert(:table => table, :place => 0)
  end

  public
  def update_placeholder(db, table, place)
    @logger.info("set placeholder to #{place}")
    since = db[SINCE_TABLE]
    since.where(:table => table).update(:place => place)
  end

  public 
  def get_all_tables(db)
    @logger.info("fetch tables")
    return db["SELECT * FROM sqlite_master WHERE type = 'table' AND tbl_name = 'EventLog' AND tbl_name NOT LIKE 'sqlite_%'"].map { |t| t[:name] }.select { |n| !@exclude_tables.include?(n) }
  end
  
  public
  def get_n_rows_from_table(db, table, offset, limit)
  	textquery = "
	SELECT
    EventLog.[date] as TrueDateEpoch
	  , strftime('%Y-%m-%dT%H:%M:%S',
                EventLog.[date]/10000 - 62135596800,
                'unixepoch') as curetimestamp
	  , (EventLog.[date] - 62135596800 * 10000) / 10000 as microsectimestamp
    , EventLog.[connectID] as connectID
	  , EventLog.[session] as session
		, EventLog.[transactionStatus] as transactionStatus		
		, EventLog.[transactionID] as transactionID
		, EventLog.[severity] as severity		
		, UserCodes.[name] as UserName
		, ComputerCodes.[name] as Client				
		, CASE WHEN EventLog.[transactionDate] = 0 THEN 0 ELSE (EventLog.[transactionDate] - 62135596800 * 10000) / 10000 END as transactionDate
		, AppCodes.[name] as ApplicationName
		, EventCodes.[name] as Event
		, EventLog.[comment] as Comment
		, metadataCodes.name as metaData
		, EventLog.[dataType] as dataType
		, EventLog.[data] as data
		, EventLog.[date] as rowID
		, EventLog.[dataPresentation] as dataPresentation
		, WorkServerCodes.[name] as Server
		, primaryPortCodes.[name] as PrimaryPort
		, secondaryPortCodes.[name] as SecondaryPort
		FROM [EventLog] as EventLog
		LEFT JOIN [UserCodes] as UserCodes
		ON 
		EventLog.userCode = UserCodes.[code]
		LEFT JOIN [ComputerCodes] as ComputerCodes
		ON 
		EventLog.ComputerCode = ComputerCodes.[code]
		LEFT JOIN [AppCodes] as AppCodes
		ON 
		EventLog.appCode = AppCodes.[code]
		LEFT JOIN [EventCodes] as EventCodes
		ON 
		EventLog.eventCode = EventCodes.[code]
		LEFT JOIN [MetadataCodes] as metadataCodes
		ON 
		EventLog.metadataCodes = metadataCodes.[code]
		LEFT JOIN [WorkServerCodes] as WorkServerCodes
		ON 
		EventLog.WorkServerCode = WorkServerCodes.[code]
		LEFT JOIN [PrimaryPortCodes] as primaryPortCodes
		ON 
		EventLog.primaryPortCode = primaryPortCodes.[code]
		LEFT JOIN [SecondaryPortCodes] as secondaryPortCodes
		ON 
		EventLog.secondaryPortCode = secondaryPortCodes.[code]
		WHERE (EventLog.[date] > #{offset}) ORDER BY EventLog.[date] LIMIT #{limit}"
		
	return db[textquery].map { |row| row }
  end
  
  public
  def register
    require "sequel"
    require "jdbc/sqlite3" 
    @host = Socket.gethostname
    @path =  File.join(@onec_server_reg_path, @onec_base_guid, "1Cv8Log", "1Cv8.lgd")
    @logger.info("Registering sqliteonec input", :database => @path)    
	  @sinceDb = Sequel.connect("jdbc:sqlite:#{@path_since}")
  	@db = Sequel.connect("jdbc:sqlite:#{@path}") 
    @tables = get_all_tables(@db)
    @table_data = {}
    @tables.each do |table|
      init_placeholder_table(@sinceDb)
      last_place = get_placeholder(@sinceDb, @onec_base_name + table)
      @table_data[table] = { :name => table, :place => last_place }
    end
  end # def register

  public
  def run(queue)
    sleep_min = 0.01
    sleep_max = 5
    sleeptime = sleep_min

    @logger.info("Tailing sqliteonec db", :path => @path)
    while !stop?
      count = 0
      @table_data.each do |k, table|
        table_name = table[:name]
        offset = table[:place]
        @logger.debug("offset is #{offset}", :k => k, :table => table_name)
        rows = get_n_rows_from_table(@db, table_name, offset, @batch)

        count += rows.count
        @logger.debug("current rows is #{count}")

        rows.each do |row| 

          event = LogStash::Event.new("host" => @host, "message" => @path, "onecbase" => @onec_base_name)
          decorate(event)
            
          payload = Hash[
            row.map { |k, v| 
                [k.to_s, decorate_value(k.to_s, v)] 
              }
          ]  

          eventPayLoad = LogStash::Event.new(payload)

          decorate(eventPayLoad)
          event.append(eventPayLoad)

          queue << event
          @table_data[k][:place] = row[:rowID]
        end
      update_placeholder(@sinceDb, @onec_base_name + table_name, @table_data[k][:place])
    end

    if count == 0
       # nothing found in that iteration
       # sleep a bit
       @logger.info("No new rows. Sleeping.", :time => sleeptime)
       sleeptime = [sleeptime * 2, sleep_max].min

       Stud.stoppable_sleep(sleeptime) {
         stop? 
       }
		   @db.disconnect
		   @db.connect("jdbc:sqlite:#{@path}")
		  #//@db = Sequel.connect("jdbc:sqlite:#{@path}") 
    else
       sleeptime = sleep_min
       Stud.stoppable_sleep(sleeptime) {
         stop? 
       }
     end
   end # loop
  end #run

  def stop
    # nothing to do in this case so it is not necessary to define stop
    
  end

  private
  def decorate_value(key, value)
    if key.eql? "curetimestamp"
      LogStash::Timestamp.coerce(value)
    elsif value.is_a?(Time)
      # transform it to LogStash::Timestamp as required by LS
      LogStash::Timestamp.new(value)
    elsif value.is_a?(DateTime)
      # Manual timezone conversion detected.
      # This is slower, so we put it in as a conditional case.
      LogStash::Timestamp.new(Time.parse(value.to_s))
    else
      value
    end
  end

end # class Logtstash::Inputs::EventLog

