package Classes
{
   import Classes.Constants.Experiments;
   import Display.MOTD;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.BringBackWinterManager;
   import Managers.FeatureMessagingManager;
   import Transactions.TGetMOTD;
   import Widgets.Windows.BringBackWinterComingSoonWindow;
   
   public class BringBackWinterMapTrigger extends MapTrigger
   {
      
      public static const BUILT_1:String = "built_1";
      
      public static const BBW_COMINGSOON_SEEN:String = "HirosPets_comingsoon_seen";
      
      private var m_motdData:Object = null;
      
      private var m_featureDefinition:FeatureMessagingDefinition;
      
      private var m_sentForMOTDData:Boolean = false;
      
      private var m_dialogUrl:String;
      
      public function BringBackWinterMapTrigger(itemName:String, stateToSet:String = "built_1")
      {
         super(itemName,stateToSet);
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         var dialogUrlXML:XMLList = xmlData.child("dialogUrl");
         this.m_dialogUrl = dialogUrlXML[0].toString();
      }
      
      override public function onClick() : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HIROS_PETS) >= Experiments.VARIANT_HIROS_PETS)
         {
            if(FeatureMessagingManager.getInstance().isFeatureInitialized(name))
            {
               BringBackWinterManager.getInstance(name).handleHUDClick();
            }
            else if(this.m_motdData)
            {
               MOTD.displayMOTD(this.m_motdData,false);
            }
            else if(!this.m_sentForMOTDData)
            {
               this.m_featureDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(name);
               if(Boolean(this.m_featureDefinition && this.m_featureDefinition.passesIconPrereqs()) && Boolean(this.m_featureDefinition.motd != null) && this.m_featureDefinition.motd.length > 0)
               {
                  this.m_sentForMOTDData = true;
                  TransactionManager.addTransaction(new TGetMOTD(this.m_featureDefinition.motd,this.onGetMOTD),true);
               }
            }
         }
         else
         {
            UI.displayPopup(new BringBackWinterComingSoonWindow(name,this.m_dialogUrl));
            if(!Global.player.getSeenFlag(BBW_COMINGSOON_SEEN))
            {
               setState(BUILT_1);
               Global.player.setSeenFlag(BBW_COMINGSOON_SEEN);
            }
         }
      }
      
      private function onGetMOTD(amfResult:Object) : void
      {
         if(Boolean(amfResult) && amfResult.hasOwnProperty("motdSeenFlag"))
         {
            this.m_motdData = amfResult;
            this.m_sentForMOTDData = false;
            MOTD.displayMOTD(this.m_motdData,false);
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.updateState();
      }
      
      public function updateState() : void
      {
         if(Global.player.getSeenFlag(BBW_COMINGSOON_SEEN) || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MERRY_MARSHALL) >= Experiments.VARIANT_MERRY_MARSHALL)
         {
            setState(BUILT_1);
         }
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}

