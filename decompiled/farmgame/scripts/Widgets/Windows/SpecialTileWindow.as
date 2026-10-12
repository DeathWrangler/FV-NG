package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Managers.RegionAchievementManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   
   public class SpecialTileWindow extends FarmWindow
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const TITLE1_TF:String = "title1_tf";
      
      private static const TITLE2_TF:String = "title2_tf";
      
      private static const BODY_TF:String = "body_tf";
      
      private static const BODY1_TF:String = "body1_tf";
      
      private static const ACCEPT_BT:String = "accept_bt";
      
      private static const CLOSE_BT:String = "close_bt";
      
      private static const R1_MC:String = "r1_mc";
      
      private static const R2_MC:String = "r2_mc";
      
      private static const R3_MC:String = "r3_mc";
      
      private static const R4_MC:String = "r4_mc";
      
      private static const LOGO_0_MC:String = "logo_0_mc";
      
      private static const LOGO_1_MC:String = "logo_1_mc";
      
      private static const SHIPPING_MC:String = "shipping_mc";
      
      private static const TROPHY_MC:String = "trophy_mc";
      
      private var m_featureBuilding:FeatureBuilding;
      
      private var m_clickedFromTile:Boolean;
      
      public function SpecialTileWindow(building:FeatureBuilding, clickedFromTile:Boolean = false)
      {
         this.m_featureBuilding = building;
         this.m_clickedFromTile = clickedFromTile;
         var windowURL:String = "";
         if(this.m_featureBuilding.getItem().getDialogConfig("storage"))
         {
            windowURL = this.m_featureBuilding.getItem().getDialogConfig("storage").path;
         }
         else
         {
            windowURL = this.m_featureBuilding.getItem().getImageByName("ready",false);
         }
         super(windowURL,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var regionId:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            regionId = RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).getRegionIdByTotemName("xjp_" + this.m_featureBuilding.bldgName);
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow[ACCEPT_BT])
            {
               if(this.m_clickedFromTile && RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isShieldWonInRegion(regionId))
               {
                  addWidget(new FarmAnimatedTextButton(m_window.mainWindow[ACCEPT_BT],ZLocUtils.t_pk("Dialogs","Unlock"),this.unlockSpecialTile));
               }
               else
               {
                  addWidget(new FarmAnimatedTextButton(m_window.mainWindow[ACCEPT_BT],ZLocUtils.t_pk("Dialogs","totemAcceptButtonText"),this.openAchievementUI));
               }
            }
            if(m_window.mainWindow[TITLE_TF])
            {
               if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isShieldWonInRegion(regionId))
               {
                  addWidget(new FarmTextField(m_window.mainWindow[TITLE_TF],ZLocUtils.t_pk("Dialogs","totemCongratulationsTitle")));
               }
               else
               {
                  addWidget(new FarmTextField(m_window.mainWindow[TITLE_TF],ZLocUtils.t_pk("Dialogs",this.m_featureBuilding.bldgName + "Title")));
               }
            }
            if(m_window.mainWindow[TITLE1_TF])
            {
               if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isChampionFromFO())
               {
                  addWidget(new FarmTextField(m_window.mainWindow[TITLE1_TF],ZLocUtils.t_pk("Dialogs","totemCardUpgradedTitle")));
               }
               else if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isShieldWonInRegion(regionId))
               {
                  addWidget(new FarmTextField(m_window.mainWindow[TITLE1_TF],ZLocUtils.t_pk("Dialogs",this.m_featureBuilding.bldgName + "CongratulationsTitle")));
               }
               else
               {
                  addWidget(new FarmTextField(m_window.mainWindow[TITLE1_TF],ZLocUtils.t_pk("Dialogs","totemCardTitle")));
               }
            }
            if(m_window.mainWindow[BODY_TF])
            {
               if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isChampionFromFO())
               {
                  addWidget(new FarmTextField(m_window.mainWindow[BODY_TF],ZLocUtils.t_pk("Dialogs",this.m_featureBuilding.bldgName + "CongratulationsBody_champion")));
               }
               else if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isShieldWonInRegion(regionId))
               {
                  addWidget(new FarmTextField(m_window.mainWindow[BODY_TF],ZLocUtils.t_pk("Dialogs",this.m_featureBuilding.bldgName + "CongratulationsBody")));
               }
               else
               {
                  addWidget(new FarmTextField(m_window.mainWindow[BODY_TF],ZLocUtils.t_pk("Dialogs",this.m_featureBuilding.bldgName + "Body")));
               }
            }
            if(m_window.mainWindow[TITLE2_TF])
            {
               if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isChampionFromFO())
               {
                  addWidget(new FarmTextField(m_window.mainWindow[TITLE2_TF],""),false);
               }
               else if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isGotSpecialRewardFromFO())
               {
                  addWidget(new FarmTextField(m_window.mainWindow[TITLE2_TF],ZLocUtils.t_pk("Dialogs","totemShippingLicenceReceivedTitle")));
               }
               else
               {
                  addWidget(new FarmTextField(m_window.mainWindow[TITLE2_TF],ZLocUtils.t_pk("Dialogs","totemShippingLicenceTitle")));
               }
            }
            if(m_window.mainWindow[BODY1_TF])
            {
               if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isChampionFromFO())
               {
                  addWidget(new FarmTextField(m_window.mainWindow[BODY1_TF],ZLocUtils.t_pk("Dialogs","totemShippingLicenceReceivedBody_champion")));
               }
               else if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isGotSpecialRewardFromFO())
               {
                  addWidget(new FarmTextField(m_window.mainWindow[BODY1_TF],ZLocUtils.t_pk("Dialogs","totemShippingLicenceReceivedBody")));
               }
               else
               {
                  addWidget(new FarmTextField(m_window.mainWindow[BODY1_TF],ZLocUtils.t_pk("Dialogs","totemShippingLicenceBody")));
               }
            }
            if(m_window.mainWindow[TROPHY_MC])
            {
               if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isChampionFromFO() || RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isGotSpecialRewardFromFO())
               {
                  m_window.mainWindow[TROPHY_MC].visible = true;
               }
               else if(m_window.mainWindow[SHIPPING_MC])
               {
                  m_window.mainWindow[SHIPPING_MC].visible = true;
               }
            }
            if(m_window.mainWindow[CLOSE_BT])
            {
               addWidget(new FarmButton(m_window.mainWindow[CLOSE_BT],onClose));
            }
            if(m_window.mainWindow[ZLocUtils.t_pk("Dialogs",this.m_featureBuilding.bldgName + "MovieClipName")])
            {
               m_window.mainWindow[R1_MC].visible = false;
               m_window.mainWindow[R1_MC][LOGO_0_MC].visible = false;
               m_window.mainWindow[R1_MC][LOGO_1_MC].visible = false;
               m_window.mainWindow[R2_MC].visible = false;
               m_window.mainWindow[R2_MC][LOGO_0_MC].visible = false;
               m_window.mainWindow[R2_MC][LOGO_1_MC].visible = false;
               m_window.mainWindow[R3_MC].visible = false;
               m_window.mainWindow[R3_MC][LOGO_0_MC].visible = false;
               m_window.mainWindow[R3_MC][LOGO_1_MC].visible = false;
               m_window.mainWindow[R4_MC].visible = false;
               m_window.mainWindow[R4_MC][LOGO_0_MC].visible = false;
               m_window.mainWindow[R4_MC][LOGO_1_MC].visible = false;
               m_window.mainWindow[ZLocUtils.t_pk("Dialogs",this.m_featureBuilding.bldgName + "MovieClipName")].visible = true;
               if(RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).isChampionFromFO())
               {
                  m_window.mainWindow[ZLocUtils.t_pk("Dialogs",this.m_featureBuilding.bldgName + "MovieClipName")][LOGO_1_MC].visible = true;
               }
               else
               {
                  m_window.mainWindow[ZLocUtils.t_pk("Dialogs",this.m_featureBuilding.bldgName + "MovieClipName")][LOGO_0_MC].visible = true;
               }
            }
         }
      }
      
      private function openAchievementUI(e:Event = null) : void
      {
         RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).showUI();
         super.close();
      }
      
      private function unlockSpecialTile(e:Event = null) : void
      {
         var regionId:String = RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).getRegionIdByTotemName("xjp_" + this.m_featureBuilding.bldgName);
         RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).checkOutRegionSpecialTile(regionId);
         super.close();
      }
      
      override public function close() : void
      {
         RegionAchievementManager.getInstance(RegionAchievementManager.FEATURE_NAME).executeNextAction();
         super.close();
      }
   }
}

