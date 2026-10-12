package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.WinternordInnovationCommunityGoalTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.TemplateUIUtility;
   import Managers.WinternordInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class WinternordCommunityGoalsRewardWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_reward:FarmItem;
      
      private var m_rewardXML:XMLList;
      
      private var m_taskId:int;
      
      private var m_task:WinternordInnovationCommunityGoalTask;
      
      private var m_featureName:String;
      
      private var title_tf:ZwTextField;
      
      private var m_gift_mc:MovieClip;
      
      private var communityTarget:int;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_isReward:Boolean;
      
      public function WinternordCommunityGoalsRewardWindow(activeTask:WinternordInnovationCommunityGoalTask, rewardXML:XMLList, featureName:String, taskId:int = 1, isReward:Boolean = false)
      {
         super("assets/dialogs/expansion/FV_RewardDialog.swf");
         this.m_rewardXML = rewardXML;
         this.m_taskId = taskId;
         this.m_featureName = featureName;
         this.m_task = activeTask;
         this.m_dialogBackground = "assets/dialogs/winternord/RewardDialog.png";
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         this.m_isReward = isReward;
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var rewardXML:XML = null;
         var rewardName:String = null;
         var rewardQty:String = null;
         var iconUrl:String = null;
         super.postLoadComplete();
         var itemName:String = "";
         var itemCode:String = "";
         for each(rewardXML in this.m_rewardXML)
         {
            if(rewardXML != null)
            {
               rewardName = rewardXML.attribute("name").toString();
               rewardQty = rewardXML.attribute("qty").toString();
               this.m_reward = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
               itemName = this.m_reward.friendlyTitle;
               itemCode = this.m_reward.code;
            }
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GenericText",{"itemName":itemName}))) as ZwTextField;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.generic_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.generic_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.generic_tf);
               }
            }
            else if(m_window.hasOwnProperty("title_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"United We Stand!")) as ZwTextField;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext1_tf"))
            {
               addWidget(new ZwTextField(m_window["subtext1_tf"],"The Community reached its goal for Week " + this.manager.getActiveWeek() + " and you won " + rewardQty + " " + itemName + " too!"));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.subtext1_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               addWidget(new ZwTextField(m_window["subtext2_tf"],"Work together with the community each week to keep winning!"));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionGlowFilter(m_window.subtext2_tf);
               }
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               this.m_gift_mc = m_window.giftbox_mc;
               this.m_gift_mc.visible = true;
            }
            if(m_window.hasOwnProperty("accept_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Awesome!",this.onClose),true);
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
               if(iconUrl == null)
               {
                  iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
                  if(iconUrl == null)
                  {
                     iconUrl = this.m_reward.iconUrl;
                  }
               }
               addWidget(new FarmIcon(m_window["icon_mc"],iconUrl));
            }
            else if(m_window.hasOwnProperty("opf_mc"))
            {
               this.addWidget(new ObjectPreviewFrame(m_window.opf_mc,this.m_reward,null,[this.m_zoomingScale],null,"","",null,new Point(0,OFFSET_OPF_Y)));
            }
            else if(m_window.hasOwnProperty("reward_mc"))
            {
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
               if(iconUrl == null)
               {
                  iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
               }
               addWidget(new FarmIcon(m_window["reward_mc"],iconUrl));
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
         }
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.tintWindow();
            this.manager.mainWindow.enableInput = false;
         }
         if(this.manager.m_communityGoalWindow)
         {
            this.manager.m_communityGoalWindow.tintWindow();
            this.manager.mainWindow.enableInput = false;
         }
      }
      
      private function get manager() : WinternordInnovationManager
      {
         return WinternordInnovationManager.getInstance();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.manager.m_communityGoalWindow)
         {
            this.manager.m_communityGoalWindow.untintWindow();
            this.manager.m_communityGoalWindow.enableInput = true;
            this.manager.m_communityGoalWindow.refreshCommGoalWindow();
         }
         if(this.m_isReward && Boolean(this.manager.mainWindow))
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
            this.manager.mainWindow.refreshWindow();
         }
         super.onClose(event);
      }
   }
}

