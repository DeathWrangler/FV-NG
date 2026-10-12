package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class CaringTreeWindow extends FarmWindow
   {
      
      protected var m_featureBuilding:FeatureBuilding;
      
      public function CaringTreeWindow(building:FeatureBuilding)
      {
         this.m_featureBuilding = building;
         var dialogConfig:Object = this.m_featureBuilding.getDialogConfig();
         if(dialogConfig == null)
         {
            dialogConfig = this.m_featureBuilding.getItem().getDialogConfig("storage");
         }
         if(dialogConfig != null && dialogConfig.path != "")
         {
            super(dialogConfig.path,true,true);
         }
         else
         {
            GlobalEngine.assert(false,"building is missing a dialog config");
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var mainMC:Object = null;
         var buildingLevel:int = 0;
         var index:int = 0;
         var windowTitle:String = null;
         var genericMessage:String = null;
         var legalMessage:String = null;
         var visible:Boolean = false;
         var topBanner:Object = null;
         var partsNeeded:int = 0;
         var shouldShow:Boolean = false;
         var stageMessage:String = null;
         var toLevelText:String = null;
         var rewardItem:FarmItem = null;
         var iconUrl:String = null;
         var harvestsNeededMessage:String = null;
         super.postLoadComplete();
         var featureName:String = this.m_featureBuilding.getItemName();
         if(ObjectUtil.pathExists(m_window,["main_mc"]))
         {
            mainMC = m_window.main_mc;
            mainMC.visible = true;
            if(ObjectUtil.pathExists(mainMC,["title_tf"]))
            {
               windowTitle = ZLocUtils.tk_pk_asTitle(this.m_featureBuilding.getItemFriendlyName());
               addWidget(new ZwTextField(mainMC.title_tf,windowTitle));
            }
            if(ObjectUtil.pathExists(mainMC,["generic2_tf"]))
            {
               genericMessage = ZLocUtils.t("Dialogs",featureName + "GenericMessage");
               addWidget(new ZwTextField(mainMC.generic2_tf,genericMessage));
            }
            if(ObjectUtil.pathExists(mainMC,["link_mc","generic_tf"]))
            {
               legalMessage = ZLocUtils.t("Dialogs",featureName + "LegalMessage");
               addWidget(new FarmAnimatedTextButton(mainMC.link_mc,legalMessage,this.onLinkClicked));
            }
            if(ObjectUtil.pathExists(mainMC,["whatisthis_mc"]))
            {
               addWidget(new FarmAnimatedButton(mainMC.whatisthis_mc,this.howDoesThisWorkClick));
            }
            buildingLevel = this.m_featureBuilding.storageLevel;
            for(index = 1; ObjectUtil.pathExists(mainMC,["decorationStage" + index + "_mc"]); index++)
            {
               visible = false;
               if(buildingLevel - 1 == index)
               {
                  visible = true;
               }
               mainMC["decorationStage" + index + "_mc"].visible = visible;
            }
            if(ObjectUtil.pathExists(mainMC,["topbanner_mc"]))
            {
               topBanner = mainMC.topbanner_mc;
               if(ObjectUtil.pathExists(topBanner,["stage_tf"]))
               {
                  stageMessage = ZLocUtils.t("Dialogs",featureName + "StageMessage",{"level":buildingLevel});
                  addWidget(new ZwTextField(topBanner.stage_tf,stageMessage));
               }
               partsNeeded = this.m_featureBuilding.nextExpansionPartsNumberNeeded();
               shouldShow = partsNeeded > 0;
               if(ObjectUtil.pathExists(topBanner,["points_tf"]))
               {
                  toLevelText = ZLocUtils.t("Dialogs",featureName + "ToLevelMessage");
                  addWidget(new ZwTextField(topBanner.points_tf,toLevelText),shouldShow);
               }
               if(ObjectUtil.pathExists(topBanner,["levelup_mc"]))
               {
                  topBanner.levelup_mc.visible = shouldShow;
               }
               if(ObjectUtil.pathExists(topBanner,["icon_mc"]))
               {
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_featureBuilding.expand.getNextUpgradeAward());
                  iconUrl = "";
                  if(rewardItem != null)
                  {
                     iconUrl = rewardItem.iconUrl;
                  }
                  addWidget(new FarmIcon(topBanner.icon_mc,iconUrl),shouldShow);
               }
               if(ObjectUtil.pathExists(topBanner,["body_tf"]))
               {
                  harvestsNeededMessage = ZLocUtils.t("Dialogs",featureName + "HarvestsNeededMessage",{"need":partsNeeded});
                  addWidget(new ZwTextField(topBanner.body_tf,harvestsNeededMessage),shouldShow);
               }
            }
         }
      }
      
      private function onLinkClicked(event:Event) : void
      {
         var linkUrl:String = ZLocUtils.t("Dialogs","MOTDCharityTreeLegalLink");
         navigateToURL(new URLRequest(linkUrl),"_blank");
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         TutorialUI.displayBuildingTutorialWindow(this.m_featureBuilding,this.m_featureBuilding.getItem().prefixUrl);
      }
   }
}

