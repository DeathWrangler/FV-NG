package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.IsraelInnovationManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class IsraelCommunityGoalsRewardWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      private var m_dialogBackground:String;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_reward:FarmItem;
      
      private var m_rewardXML:XMLList;
      
      private var m_taskId:int;
      
      private var m_taskList:Array;
      
      private var m_featureName:String;
      
      private var title_tf:ZwTextField;
      
      private var m_gift_mc:MovieClip;
      
      private var communityTarget:int;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_isReward:Boolean;
      
      public function IsraelCommunityGoalsRewardWindow(activeTaskList:Array, rewardXML:XMLList, featureName:String, taskId:int = 1, isReward:Boolean = false)
      {
         super("assets/dialogs/expansion/FV_RewardDialog.swf");
         this.m_rewardXML = rewardXML;
         this.m_taskId = taskId;
         this.m_featureName = featureName;
         this.m_taskList = activeTaskList;
         this.m_dialogBackground = "assets/dialogs/israel/RewardDialog.png";
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
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],"CONGRATS!")) as ZwTextField;
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
                  TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
                  TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext1_tf"))
            {
               if(this.m_taskId == 1)
               {
                  addWidget(new ZwTextField(m_window["subtext1_tf"],"The Community has completed " + this.m_taskList[this.m_taskId - 1].communityGoal + " tasks on the Orderboard this week!"));
               }
               else if(this.m_taskId == 2)
               {
                  addWidget(new ZwTextField(m_window["subtext1_tf"],"The Community has shared " + this.m_taskList[this.m_taskId - 1].communityGoal + " Bundles of plenty this week!"));
               }
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.subtext1_tf);
               }
            }
            if(m_window.hasOwnProperty("subtext2_tf"))
            {
               addWidget(new ZwTextField(m_window["subtext2_tf"],"You have won " + rewardQty + " " + itemName + "!"));
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
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Awesome",this.onClose),true);
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
      }
      
      private function get manager() : IsraelInnovationManager
      {
         return IsraelInnovationManager.getInstance();
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
         super.onClose(event);
      }
   }
}

