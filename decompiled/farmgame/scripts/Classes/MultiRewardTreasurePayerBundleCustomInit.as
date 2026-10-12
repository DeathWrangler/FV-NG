package Classes
{
   import Display.MOTD;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureMessagingManager;
   import Transactions.TGetMOTD;
   import flash.events.Event;
   
   public class MultiRewardTreasurePayerBundleCustomInit implements IFeatureMessagingCustomInit
   {
      
      private static var MOTD_DATA:Object = null;
      
      private static var SENT_RQST_FOR_MOTD:Boolean = false;
      
      private var m_featureName:String;
      
      public function MultiRewardTreasurePayerBundleCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      private static function setMotdData(motdData:Object) : void
      {
         MOTD_DATA = motdData;
      }
      
      private static function getMotdData() : Object
      {
         return MOTD_DATA;
      }
      
      private static function setSentRqstForMotd(sentRqstForMotd:Boolean) : void
      {
         SENT_RQST_FOR_MOTD = sentRqstForMotd;
      }
      
      private static function getSentRqstForMotd() : Boolean
      {
         return SENT_RQST_FOR_MOTD;
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,this.showMOTD);
      }
      
      private function showMOTD(event:Event = null) : void
      {
         if(getSentRqstForMotd())
         {
            MOTD.displayMOTD(getMotdData());
         }
         else
         {
            TransactionManager.addTransaction(new TGetMOTD("MOTD_PAYER_BUNDLE_MIDWEST",this.onGetMOTD),true);
         }
      }
      
      private function onGetMOTD(motdData:Object) : void
      {
         if(Boolean(motdData) && motdData.hasOwnProperty("motdSeenFlag"))
         {
            setSentRqstForMotd(true);
            setMotdData(motdData);
            MOTD.displayMOTD(motdData,false);
         }
      }
   }
}

