package Init
{
   import Engine.Init.InitializationAction;
   import ZLocalization.LocaleLoader;
   import flash.events.Event;
   
   public class ZLocalizationInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "ZLocalizationInit";
      
      private var m_localeUrl:String = "";
      
      private var m_localeLoader:LocaleLoader = null;
      
      public function ZLocalizationInit(localeUrl:String)
      {
         super(INIT_ID);
         this.m_localeUrl = localeUrl;
         addDependency(MarketSettingsInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         var isCompressed:Boolean = false;
         var isXml:Boolean = false;
         this.m_localeLoader = new LocaleLoader(this.m_localeUrl,this.onInitComplete,isCompressed,isXml);
      }
      
      private function onInitComplete() : void
      {
         ZLoc.instance = this.m_localeLoader.localizer;
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

