package Widgets.Windows
{
   import Classes.RuntimeDrivenLootableFixedFeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.RuntimeDrivenCharityWindow;
   import Engine.Managers.StatsManager;
   import Managers.FarmGameSettingsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class RuntimeDrivenBuildingRewardWindow extends FarmWindow
   {
      
      private var m_reward:FarmItem = null;
      
      private var m_rewardObject:Object;
      
      private var m_callback:Function = null;
      
      private var m_building:RuntimeDrivenLootableFixedFeatureBuilding;
      
      private var m_useFinalUIOverlay:Boolean;
      
      private var m_featureName:String;
      
      public function RuntimeDrivenBuildingRewardWindow(building:RuntimeDrivenLootableFixedFeatureBuilding, rewardObject:Object, useFinalUI:Boolean = false, buttonCallback:Function = null)
      {
         var rewardDialogStr:String = null;
         this.m_building = building;
         this.m_featureName = building.featureName;
         this.m_useFinalUIOverlay = useFinalUI;
         this.m_reward = Global.farmGameSettingsManager.getFarmItemByName(rewardObject.itemName);
         this.m_callback = buttonCallback;
         this.m_rewardObject = rewardObject;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            rewardDialogStr = this.m_building.getItem().getStringFromDataSource("completeRewardDialog");
         }
         else
         {
            rewardDialogStr = this.m_building.getItem().xml.completeRewardDialog.toString();
         }
         super(rewardDialogStr);
      }
      
      override protected function postLoadComplete() : void
      {
         var buildingConfig:XML = null;
         var rewardTitle:String = null;
         var unitExperimentName:String = null;
         var experimentVariant:int = 0;
         var totalText:String = null;
         var buttonCallback:Function = null;
         var iconUrl:String = null;
         super.postLoadComplete();
         var itemName:String = "";
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
         }
         StatsManager.count(RuntimeDrivenLootableFixedFeatureBuilding.RUNTIME_BUILDING,this.m_featureName,"dialog_reward",itemName,"view");
         if(m_window != null)
         {
            if(m_window.title_tf)
            {
               rewardTitle = ZLocUtils.t("Dialogs",this.m_featureName + "RewardTitle");
               if(rewardTitle == "" || rewardTitle == null)
               {
                  rewardTitle = ZLocUtils.t("Dialogs","Congrats");
               }
               addWidget(new ZwTextField(m_window.title_tf,rewardTitle));
            }
            buildingConfig = RuntimeDrivenLootableFixedFeatureBuilding.getRuntimeBuildingConfig(this.m_featureName);
            if(buildingConfig)
            {
               unitExperimentName = buildingConfig.@unitExperiment;
               if(unitExperimentName)
               {
                  experimentVariant = Global.experimentManager.getExperimentVariant(unitExperimentName);
                  if(Boolean(m_window.item_tf) && Boolean(this.m_rewardObject["milestone" + experimentVariant]))
                  {
                     totalText = this.m_useFinalUIOverlay ? ZLocUtils.t("Dialogs",this.m_featureName + "GoalThanks") : ZLocUtils.t("Dialogs",this.m_featureName + "Goal",{"totalText":this.m_rewardObject["milestone" + experimentVariant]});
                     addWidget(new ZwTextField(m_window.item_tf,totalText));
                  }
               }
            }
            if(m_window.info_tf)
            {
               addWidget(new ZwTextField(m_window.info_tf,ZLocUtils.t("Dialogs",this.m_featureName + "Info",{"itemName":itemName})));
            }
            if(m_window.accept_bt)
            {
               buttonCallback = onClose;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Awesome"),buttonCallback));
            }
            if(m_window.icon_mc)
            {
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
               if(iconUrl == null)
               {
                  iconUrl = this.m_reward.iconUrl;
               }
               addWidget(new FarmIcon(m_window.icon_mc,iconUrl));
            }
            if(Boolean(m_window.final_mc) && this.m_useFinalUIOverlay)
            {
               addWidget(new ZwBaseWidget(m_window.final_mc));
            }
            if(Boolean(m_window.item2_tf) && this.m_useFinalUIOverlay)
            {
               addWidget(new ZwTextField(m_window.item2_tf,ZLocUtils.t("Dialogs",this.m_featureName + "Finish")));
            }
         }
      }
      
      override public function close() : void
      {
         var url:String = null;
         RuntimeDrivenCharityWindow.setFinalRewardOverlayFlag(this.m_useFinalUIOverlay);
         if(this.m_useFinalUIOverlay)
         {
            url = ZLocUtils.t("Dialogs",this.m_featureName + "Legal");
            navigateToURL(new URLRequest(url),"_blank");
         }
         this.m_building.showLookInsideDialogFromConfig(Global.farmGameSettingsManager.getBuildingDialogConfig(this.m_building.featureName));
         super.close();
      }
   }
}

