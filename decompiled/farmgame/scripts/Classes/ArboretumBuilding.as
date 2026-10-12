package Classes
{
   import Classes.util.OnboardingUtil;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   import Widgets.Windows.Orchards.OrchardManagementWindow;
   import flash.events.Event;
   
   public class ArboretumBuilding extends OrchardBuilding
   {
      
      protected var m_buildingName:String;
      
      protected var m_orchardManagementWindow:OrchardManagementWindow;
      
      public function ArboretumBuilding(buildingType:String = null)
      {
         var buildingName:String = null;
         var className:String = null;
         var item:XML = null;
         super(buildingType);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(m_item.hasPropertyInDataSource("buildingName"))
            {
               buildingName = m_item.getStringFromDataSource("buildingName");
            }
            else
            {
               className = m_item.getStringFromDataSource("className");
            }
         }
         else
         {
            item = m_item.xml;
            if(item.hasOwnProperty("@buildingName") && Boolean(item.@buildingName.length()))
            {
               buildingName = item.@buildingName;
            }
            else
            {
               className = item.@className;
            }
         }
         if(buildingName)
         {
            this.m_buildingName = buildingName;
         }
         else
         {
            this.m_buildingName = className;
            this.m_buildingName = this.m_buildingName.substring(0,this.m_buildingName.indexOf("ConstructionBuilding"));
         }
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         this.m_orchardManagementWindow = new OrchardManagementWindow(this,this.m_buildingName);
         this.m_orchardManagementWindow.addEventListener(Event.CLOSE,this.onStorageDialogClose);
         var addToQueue:Boolean = false;
         if(OnboardingUtil.hasOnboardingAward("ArboretumFrame"))
         {
            TutorialUI.displayOrchardsTutorialWindow(this,true);
            addToQueue = true;
         }
         UI.displayPopup(this.m_orchardManagementWindow,addToQueue);
      }
      
      private function onStorageDialogClose(event:Event) : void
      {
         if(this.m_orchardManagementWindow)
         {
            this.m_orchardManagementWindow.removeEventListener(Event.CLOSE,this.onStorageDialogClose);
            this.m_orchardManagementWindow = null;
         }
         var uiObject:Object = {
            "dialog":"assets/dialogs/FV_motd_grove1.swf",
            "text":"Dialogs:MOTD_ArboretumOnboarding_Text",
            "title":"Dialogs:PlaceNow",
            "buttonText":"Dialogs:PlaceNow"
         };
         OnboardingUtil.conditionallySurfaceOnboardingAward("ArboretumFrame",uiObject);
      }
      
      override public function getToolTipCapacityText() : String
      {
         return ZLocUtils.t("Items",this.m_buildingName + "_capacity",{
            "quantity":m_count,
            "maximum":capacity
         });
      }
      
      override public function onObjectDrop() : void
      {
         super.onObjectDrop();
         var actionCountKey:String = "ArboretumTutorialAutoPop";
         var actionCount:int = Global.player.getActionCount(actionCountKey);
         var limit:int = Global.farmGameSettingsManager.getInt("ArboretumTutorialAutoPopLimit",2);
         if(actionCount < limit)
         {
            Global.player.incrementActionCount(actionCountKey,true);
            TutorialUI.displayOrchardsTutorialWindow(this);
         }
      }
   }
}

