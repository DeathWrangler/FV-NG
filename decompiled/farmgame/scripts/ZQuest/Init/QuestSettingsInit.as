package ZQuest.Init
{
   import Engine.Init.InitializationAction;
   import Engine.Managers.ErrorManager;
   import Engine.Utilities;
   import ZQuest.Classes.Quest;
   import ZQuest.Classes.QuestComponentOptions;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class QuestSettingsInit extends InitializationAction
   {
      
      private static var m_instance:QuestSettingsInit;
      
      public static const INIT_ID:String = "ZQuestSettingsInit";
      
      private var m_settingsUrl:String;
      
      private var m_settingsUrlBackup:String;
      
      protected var m_xml:XMLList;
      
      protected var m_quests:Dictionary = new Dictionary();
      
      protected var m_rawXml:XML;
      
      private var m_questOptions:QuestComponentOptions;
      
      private var m_memstoreToNameMap:Dictionary = new Dictionary();
      
      private var m_initMemstoreMap:Boolean = false;
      
      public function QuestSettingsInit(param1:String, param2:QuestComponentOptions, param3:String = "")
      {
         super(INIT_ID);
         this.m_settingsUrl = param1;
         this.m_settingsUrlBackup = param3;
         this.m_questOptions = param2;
         m_instance = this;
      }
      
      public static function getInstance() : QuestSettingsInit
      {
         return m_instance;
      }
      
      override public function execute() : void
      {
         var _loc1_:URLLoader = new URLLoader(new URLRequest(this.m_settingsUrl));
         _loc1_.dataFormat = URLLoaderDataFormat.BINARY;
         _loc1_.addEventListener(Event.COMPLETE,this.onConfigXmlLoaded);
         _loc1_.addEventListener(IOErrorEvent.IO_ERROR,this.onXmlError,false,0,true);
         _loc1_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onXmlError,false,0,true);
      }
      
      private function onXmlError(param1:ErrorEvent) : void
      {
         var _loc2_:String = this.m_settingsUrl;
         if(this.m_settingsUrlBackup != "")
         {
            _loc2_ = this.m_settingsUrlBackup;
         }
         var _loc3_:URLLoader = new URLLoader(new URLRequest(_loc2_));
         _loc3_.dataFormat = URLLoaderDataFormat.BINARY;
         _loc3_.addEventListener(Event.COMPLETE,this.onConfigXmlLoaded);
         _loc3_.addEventListener(IOErrorEvent.IO_ERROR,this.onXmlRetryError,false,0,true);
         _loc3_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onXmlRetryError,false,0,true);
      }
      
      private function onXmlRetryError(param1:ErrorEvent) : void
      {
         var _loc2_:String = "Failed to load config file.";
         _loc2_ += ",source=QuestSettingsInit.onXmlRetryError";
         _loc2_ += ",url=" + this.m_settingsUrl;
         _loc2_ += ",errorType=" + param1.type;
         ErrorManager.addError(_loc2_);
         dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
      }
      
      protected function onConfigXmlLoaded(param1:Event) : void
      {
         var uncompressedData:String = null;
         var errorMessage:String = null;
         var xml:XML = null;
         var event:Event = param1;
         try
         {
            uncompressedData = Utilities.uncompress(event.target.data);
         }
         catch(error:Error)
         {
            errorMessage = "Failed to uncompress data.";
            errorMessage += ",source=QuestSettingInit.onConfigXmlLoaded";
            errorMessage += ",error=" + error.message;
            ErrorManager.addError(errorMessage);
         }
         if(uncompressedData)
         {
            xml = XML(uncompressedData);
            if(GlobalEngine.isFlashVarSetAndTrue("MEMORY_CLEANUP_LOCAL_DATA_GC"))
            {
               event.target.data.clear();
               event.target.data = null;
               uncompressedData = null;
            }
            this.m_rawXml = xml;
            this.m_xml = xml..quests;
            if(this.m_xml.length > 0)
            {
               this.m_xml = this.m_xml[0];
            }
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      public function getItemByName(param1:String) : Quest
      {
         var _loc3_:XML = null;
         var _loc2_:Quest = this.m_quests[param1];
         if(_loc2_ == null)
         {
            _loc3_ = this.getQuestXMLByName(param1);
            if(_loc3_ != null)
            {
               _loc2_ = new this.m_questOptions.questClass(_loc3_);
               this.m_quests[param1] = _loc2_;
            }
         }
         return _loc2_;
      }
      
      protected function getQuestXMLByName(param1:String) : XML
      {
         var list:XMLList = null;
         var result:XML = null;
         var nameStr:String = param1;
         list = this.m_rawXml.quest.(@name == nameStr);
         result = null;
         if(list.length())
         {
            result = list[0];
         }
         return result;
      }
      
      public function getNamedQuestsFromMemstoreIds(param1:Array, param2:Boolean = false) : Array
      {
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc3_:Array = new Array();
         if(param2)
         {
            this.initializeMemstoreToNameMap();
         }
         _loc4_ = 0;
         _loc5_ = param1.length;
         while(_loc4_ < _loc5_)
         {
            _loc7_ = param1[_loc4_];
            _loc6_ = this.getQuestNameFromMemStoreIdAndAddToCache(_loc7_);
            if(_loc6_)
            {
               _loc3_.push(_loc6_);
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function initializeMemstoreToNameMap() : void
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         var _loc3_:XML = null;
         var _loc4_:String = null;
         if(this.m_initMemstoreMap == true)
         {
            return;
         }
         for each(_loc1_ in this.m_rawXml.quest)
         {
            _loc2_ = _loc1_.@memStoreId;
            _loc3_ = _loc1_[0];
            _loc4_ = _loc3_.attribute("name").toString();
            this.m_memstoreToNameMap[_loc2_] = _loc4_;
         }
         this.m_initMemstoreMap = true;
      }
      
      public function getQuestNameFromMemStoreIdAndAddToCache(param1:String) : String
      {
         if(this.m_initMemstoreMap == false)
         {
            this.initializeMemstoreToNameMap();
            this.m_initMemstoreMap = true;
         }
         return this.m_memstoreToNameMap[param1];
      }
      
      public function get isClientPredictionEnabled() : Boolean
      {
         return this.m_questOptions.questUtility != null;
      }
      
      public function get getClientPredictionClass() : Class
      {
         return this.m_questOptions.questUtility;
      }
   }
}

