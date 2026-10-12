package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FrontierInnovationForageRewardPopUp extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 3;
      
      private static const FEATURE_NAME:String = "FrontierInnovation";
      
      private var m_featureName:String = FEATURE_NAME;
      
      private const TITLE_TF:String = "title_tf";
      
      private const SUBTEXT1_TF:String = "subtext1_tf";
      
      private const QUANTUTY0_TF:String = "quantity0_tf";
      
      private const QUANTUTY1_TF:String = "quantity1_tf";
      
      private const QUANTUTY2_TF:String = "quantity2_tf";
      
      private const ACCEPT_BT:String = "accept_bt";
      
      private const BODY_TF:String = "body_tf";
      
      private const TEXT_BODY:String = "_description";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const SIZE_MC:String = "size_mc";
      
      private const BG_MC:String = "bg";
      
      private const RES_BG_MC:String = "res_bg";
      
      private const COUNT_TF:String = "count_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private const CLOSE_BT:String = "close_bt";
      
      private const ICON0_MC:String = "reward0_mc";
      
      private const ICON1_MC:String = "reward1_mc";
      
      private const ICON2_MC:String = "reward2_mc";
      
      private var m_acceptdBt:FarmAnimatedTextButton;
      
      private var m_forageAreaData:Object;
      
      private var m_sizeMc:MovieClip;
      
      private var m_BgMc:MovieClip;
      
      private var m_resBgMc:MovieClip;
      
      private var m_icon0Mc:FarmIcon;
      
      private var m_icon1Mc:FarmIcon;
      
      private var m_icon2Mc:FarmIcon;
      
      internal var managerObject:Object;
      
      public function FrontierInnovationForageRewardPopUp(forageAreaData:Object)
      {
         this.managerObject = this.manager;
         this.m_forageAreaData = forageAreaData;
         var dialogURL:String = this.manager.getForageRewardPopUp();
         var totalScenes:int = NUM_TUTORIAL_SCENES;
         var tutorailFeatureName:String = FEATURE_NAME + "ForageRewardPopUp";
         super(tutorailFeatureName,dialogURL,totalScenes);
      }
      
      protected function onClick() : void
      {
      }
      
      override protected function postLoadComplete() : void
      {
         var resource0Count:int = 0;
         var resource1Count:int = 0;
         var resource2Count:int = 0;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Foraging Successful"));
         }
         if(m_window.hasOwnProperty(this.SUBTEXT1_TF))
         {
            addWidget(new ZwTextField(m_window[this.SUBTEXT1_TF],"You found these resources at the " + this.m_forageAreaData["AreaName"]));
         }
         var areaResources:Array = this.m_forageAreaData["AreaResources"];
         var barnInventoryCount:int = this.manager.getBarnInventoryCount();
         var item0:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(areaResources[0]);
         if(m_window.hasOwnProperty(this.QUANTUTY0_TF))
         {
            addWidget(new ZwTextField(m_window[this.QUANTUTY0_TF],item0.friendlyTitle));
            resource0Count = this.manager.getResourceCountByItemCode(areaResources[0]);
            FarmStatsManager.count(this.m_featureName,"Foraging",this.m_forageAreaData["AreaName"],item0.name,(resource0Count + 1).toString(),"",barnInventoryCount + 1);
         }
         if(m_window.hasOwnProperty(this.ICON0_MC))
         {
            addWidget(this.m_icon0Mc = new FarmIcon(m_window[this.ICON0_MC]));
            this.m_icon0Mc.visible = true;
            this.m_icon0Mc.loadIcon(item0.icon);
            this.m_icon0Mc.setIconSize(50,50);
         }
         var item1:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(areaResources[1]);
         if(m_window.hasOwnProperty(this.QUANTUTY1_TF))
         {
            addWidget(new ZwTextField(m_window[this.QUANTUTY1_TF],item1.friendlyTitle));
            resource1Count = this.manager.getResourceCountByItemCode(areaResources[1]);
            FarmStatsManager.count(this.m_featureName,"Foraging",this.m_forageAreaData["AreaName"],item1.name,(resource1Count + 1).toString(),"",barnInventoryCount + 2);
         }
         if(m_window.hasOwnProperty(this.ICON1_MC))
         {
            addWidget(this.m_icon1Mc = new FarmIcon(m_window[this.ICON1_MC]));
            this.m_icon1Mc.visible = true;
            this.m_icon1Mc.loadIcon(item1.icon);
            this.m_icon1Mc.setIconSize(50,50);
         }
         var item2:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(areaResources[2]);
         if(m_window.hasOwnProperty(this.QUANTUTY2_TF))
         {
            addWidget(new ZwTextField(m_window[this.QUANTUTY2_TF],item2.friendlyTitle));
            resource2Count = this.manager.getResourceCountByItemCode(areaResources[2]);
            FarmStatsManager.count(this.m_featureName,"Foraging",this.m_forageAreaData["AreaName"],item2.name,(resource2Count + 1).toString(),"",barnInventoryCount + 3);
         }
         if(m_window.hasOwnProperty(this.ICON2_MC))
         {
            addWidget(this.m_icon2Mc = new FarmIcon(m_window[this.ICON2_MC]));
            this.m_icon2Mc.visible = true;
            this.m_icon2Mc.loadIcon(item2.icon);
            this.m_icon2Mc.setIconSize(50,50);
         }
         if(m_window.hasOwnProperty(this.ACCEPT_BT))
         {
            addWidget(this.m_acceptdBt = new FarmAnimatedTextButton(m_window[this.ACCEPT_BT],"Awesome",this.onForageRewardPopUp));
            this.m_acceptdBt.visible = true;
            this.m_acceptdBt.enabled = true;
         }
         if(m_window.hasOwnProperty(this.BG_MC))
         {
            this.m_BgMc = m_window.bg as MovieClip;
            this.m_BgMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.RES_BG_MC))
         {
            this.m_resBgMc = m_window.res_bg as MovieClip;
            this.m_resBgMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.SIZE_MC))
         {
            this.m_sizeMc = m_window.size_mc as MovieClip;
            this.m_sizeMc.visible = true;
         }
      }
      
      public function onForageRewardPopUp(event:Event) : void
      {
         this.m_acceptdBt.enabled = false;
         this.manager.onForageSucessPopUp();
      }
      
      private function get manager() : FrontierInnovationManager
      {
         return FrontierInnovationManager.getInstance(FEATURE_NAME);
      }
   }
}

