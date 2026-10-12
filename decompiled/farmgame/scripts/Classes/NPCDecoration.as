package Classes
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.MOTD;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.BringBackWinterManager;
   import Managers.FeatureMessagingManager;
   import Transactions.TGetMOTD;
   import Widgets.Windows.BringBackWinterComingSoonWindow;
   
   public class NPCDecoration extends Decoration
   {
      
      public static const BUILT_0:String = "built_0";
      
      public static const BUILT_1:String = "built_1";
      
      private var m_featureName:String;
      
      private var m_motdData:Object = null;
      
      private var m_featureDefinition:FeatureMessagingDefinition;
      
      private var m_sentForMOTDData:Boolean = false;
      
      public function NPCDecoration(itemName:String = null)
      {
         super(itemName);
         var npcItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.m_featureName = npcItem.featureName;
         if(this.m_featureName == "")
         {
            this.m_featureName = "bring_back_christmas";
         }
      }
      
      override public function getCurrentImageName() : String
      {
         return BUILT_1;
      }
      
      override public function onClick() : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BBEASTER) >= Experiments.VARIANT_BBEASTER)
         {
            if(FeatureMessagingManager.getInstance().isFeatureInitialized(this.m_featureName))
            {
               BringBackWinterManager.getInstance(this.m_featureName).handleHUDClick();
            }
            else if(this.m_motdData)
            {
               MOTD.displayMOTD(this.m_motdData,false);
            }
            else if(!this.m_sentForMOTDData)
            {
               this.m_featureDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.m_featureName);
               if(Boolean(this.m_featureDefinition && this.m_featureDefinition.passesIconPrereqs()) && Boolean(this.m_featureDefinition.motd != null) && this.m_featureDefinition.motd.length > 0)
               {
                  this.m_sentForMOTDData = true;
                  TransactionManager.addTransaction(new TGetMOTD(this.m_featureDefinition.motd,this.onGetMOTD),true);
               }
               else
               {
                  super.onClick();
               }
            }
         }
         else
         {
            UI.displayPopup(new BringBackWinterComingSoonWindow());
         }
      }
      
      override protected function getMenuItems() : Array
      {
         var item:FarmItem = this.getItem();
         var menuItems:Array = new Array();
         if(item.allowMove)
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            });
         }
         return menuItems;
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
   }
}

