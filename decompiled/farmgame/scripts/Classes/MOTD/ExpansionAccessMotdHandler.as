package Classes.MOTD
{
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.ExpansionData;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TExpansionWorldAccess;
   import Transactions.TSawSpecificMOTD;
   import Widgets.Windows.Expansion.ExpansionOnboardingWindow;
   import Widgets.Windows.Expansion.MeadowsOnboardingWindow;
   import Widgets.Windows.MOTDTutorialWindow;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   
   public class ExpansionAccessMotdHandler extends RepeatableMOTDHandler
   {
      
      protected static const SEASON_ID:String = "seasonId";
      
      private static var m_windowTypes:Array = [ExpansionOnboardingWindow,MeadowsOnboardingWindow];
      
      protected static const GENERAL_ACCESS_TYPE:String = "generalAccess";
      
      protected var m_expansionData:ExpansionData;
      
      protected var m_access:ExpansionAccess;
      
      protected var m_expansionOnboardingWindow:ExpansionOnboardingWindow;
      
      protected var m_addPopupToQueue:Boolean;
      
      protected var m_hideFirstTimeClose:Boolean = false;
      
      public function ExpansionAccessMotdHandler(currentMOTD:Object, addPopupToQueue:Boolean = true)
      {
         super(currentMOTD);
         this.m_addPopupToQueue = addPopupToQueue;
         this.m_hideFirstTimeClose = m_currentMOTD["hideCloseFirstTime"];
         var worldId:String = m_currentMOTD["worldType"];
         if(worldId)
         {
            this.m_expansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
            if(this.m_expansionData == null)
            {
               throw new Error("Invalid expansion MOTD, could not find expansion definition for world: " + worldId);
            }
            this.m_access = this.m_expansionData.getAccessOfType(this.accessType);
            if(this.m_access == null)
            {
               throw new Error("Expansion world \'" + this.m_expansionData.worldId + "\' does not support access type: " + this.accessType);
            }
            return;
         }
         throw new Error("Invalid expansion MOTD, null worldId [seenFlag=" + m_currentMOTD["motdSeenFlag"] + "]");
      }
      
      protected function get accessType() : String
      {
         return ExpansionAccess.TYPE_GENERAL;
      }
      
      protected function get brochureButtonZLocKey() : String
      {
         return "LetsGo";
      }
      
      protected function get assetPath() : String
      {
         return this.m_expansionData.motdAssets[GENERAL_ACCESS_TYPE][ExpansionData.KEY_ASSET];
      }
      
      protected function get onBoardingWindowClass() : String
      {
         var windowClass:String = this.m_expansionData.motdAssets[GENERAL_ACCESS_TYPE][ExpansionData.KEY_WINDOWCLASS];
         if(windowClass == null || windowClass == "")
         {
            windowClass = "Widgets.Windows.Expansion.ExpansionOnboardingWindow";
         }
         return windowClass;
      }
      
      override public function execute() : void
      {
         var featureName:String = null;
         var expansionOnboardingWindowClass:Class = getDefinitionByName(this.onBoardingWindowClass) as Class;
         var FTUECallback:Function = this.FTUEPath != "" ? this.FTUEClick : null;
         if(Boolean(m_currentMOTD) && Boolean(m_currentMOTD.customActionParams) && Boolean(m_currentMOTD.customActionParams.featureName))
         {
            featureName = m_currentMOTD.customActionParams.featureName;
         }
         this.m_expansionOnboardingWindow = new expansionOnboardingWindowClass(this.assetPath,ZLocUtils.t("Dialogs",this.brochureButtonZLocKey),this.acceptMOTD,this.closeMOTD,this.m_access,this.m_expansionData.worldId,FTUECallback,featureName) as ExpansionOnboardingWindow;
         this.m_expansionOnboardingWindow.setHideFirstTimeClose(this.m_hideFirstTimeClose);
         UI.displayPopup(this.m_expansionOnboardingWindow,this.m_addPopupToQueue);
         super.execute();
      }
      
      override protected function acceptMOTD() : void
      {
         this.initiateTravel();
      }
      
      protected function initiateTravel() : void
      {
         if(Global.worldManager.accessExpansionTransactionInProgress())
         {
            ztrack("start_travel");
            dispatchEvent(new Event(Event.COMPLETE));
            removeAllEventListeners();
         }
         else if(!Global.worldManager.hasUnlockedWorld(this.m_expansionData.worldId) || WorldSeasonsManager.getInstance().isUserInSeasonOne(this.m_expansionData.worldId))
         {
            super.acceptMOTD();
            TransactionManager.addTransaction(new TExpansionWorldAccess(this.m_expansionData.worldId,this.m_access.type,true,this.m_expansionOnboardingWindow.getOptionId()),true);
            if(!this.m_addPopupToQueue)
            {
               UI.clearPopupQueue();
            }
         }
         else
         {
            ztrack("start_travel");
            TransactionManager.addTransaction(new TSawSpecificMOTD(m_currentMOTD,false));
            dispatchEvent(new Event(Event.COMPLETE));
            removeAllEventListeners();
            Global.worldManager.swapFarm(this.m_expansionData.worldId,false);
         }
      }
      
      override protected function closeMOTD() : void
      {
         if(Global.worldManager.hasUnlockedWorld(this.m_expansionData.worldId))
         {
            Global.player.setMotdSeenFlag(m_currentMOTD.motdSeenFlag);
         }
         super.closeMOTD();
      }
      
      protected function get FTUEPath() : String
      {
         var result:String = "";
         if(Boolean(this.m_expansionData) && Boolean(this.m_expansionData.motdAssets) && Boolean(this.m_expansionData.motdAssets[this.m_access.type]) && Boolean(this.m_expansionData.motdAssets[this.m_access.type][ExpansionData.KEY_FTUE]))
         {
            result = this.m_expansionData.motdAssets[this.m_access.type][ExpansionData.KEY_FTUE];
         }
         return result;
      }
      
      protected function FTUEClick() : void
      {
         UI.displayPopup(new MOTDTutorialWindow(this.FTUEPath),false);
      }
   }
}

