package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.LimboInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class LimboInnovationRewardWindow extends FarmWindow
   {
      
      protected var m_featureName:String;
      
      protected var m_isBonusReward:Boolean;
      
      protected var m_buildingId:String;
      
      protected const TITLE_TF:String = "title_tf";
      
      protected const DESCP_TF:String = "description_tf";
      
      protected const REWARD_MC:String = "rewards_mc";
      
      protected const BONUS_TF:String = "bonus_tf";
      
      protected const BONUS_RAY_MC:String = "bonusRays_mc";
      
      protected const ACCEPT_BT:String = "generic_bt";
      
      protected const ICON_MC:String = "icon_mc";
      
      protected var m_bonusRayMc:MovieClip;
      
      protected const TITLE_TEXT:String = "_reward_title";
      
      protected const DESCP_TEXT:String = "_reward_descrp";
      
      protected const BONUS_TEXT:String = "_bonus_reward_descrp";
      
      protected var m_tileDesc:FarmTextField;
      
      protected var m_bonusTxt:FarmTextField;
      
      protected var m_rewardIcon:ResourcePreviewFrame;
      
      protected var m_objectPreviewFrame:ResourcePreviewFrame;
      
      public function LimboInnovationRewardWindow(assetUrl:String, featureName:String, buildingId:String, isBonusReward:Boolean)
      {
         this.m_featureName = featureName;
         this.m_isBonusReward = isBonusReward;
         this.m_buildingId = buildingId;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.REWARD_MC))
         {
            if(m_window[this.REWARD_MC].hasOwnProperty(this.TITLE_TF))
            {
               addWidget(new ZwTextField(m_window[this.REWARD_MC][this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TITLE_TEXT)));
            }
            if(m_window[this.REWARD_MC].hasOwnProperty(this.DESCP_TF))
            {
               this.m_tileDesc = new FarmTextField(m_window[this.REWARD_MC][this.DESCP_TF],"");
               addWidget(this.m_tileDesc);
               if(this.m_isBonusReward)
               {
                  this.m_tileDesc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.BONUS_TEXT,{"rewardName":this.rewardName});
               }
               else
               {
                  this.m_tileDesc.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.DESCP_TEXT,{
                     "buildingName":this.buildingName,
                     "rewardName":this.rewardName
                  });
               }
            }
            if(m_window[this.REWARD_MC].hasOwnProperty(this.BONUS_TF))
            {
               this.m_bonusTxt = new FarmTextField(m_window[this.REWARD_MC][this.BONUS_TF],"Bonus Reward!!!");
               addWidget(this.m_bonusTxt,false);
            }
            if(m_window[this.REWARD_MC].hasOwnProperty(this.BONUS_RAY_MC))
            {
               this.m_bonusRayMc = m_window[this.REWARD_MC][this.BONUS_RAY_MC] as MovieClip;
               this.m_bonusRayMc.visible = false;
            }
            if(this.m_isBonusReward)
            {
               this.m_bonusTxt.visible = true;
               this.m_bonusRayMc.visible = true;
            }
            if(m_window[this.REWARD_MC].hasOwnProperty(this.ACCEPT_BT))
            {
               addWidget(new FarmAnimatedTextButton(m_window[this.REWARD_MC][this.ACCEPT_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Awesome"),this.onAccept));
            }
            if(m_window[this.REWARD_MC].hasOwnProperty(this.ICON_MC))
            {
               addWidget(this.m_rewardIcon = new ResourcePreviewFrame(m_window[this.REWARD_MC][this.ICON_MC]));
            }
            m_window[this.REWARD_MC].visible = true;
            this.renderItem();
         }
         FarmStatsManager.count(this.m_featureName,"feature_ui","reward_window","open");
      }
      
      private function renderItem() : void
      {
         var urlsplit:Array = null;
         var exportedName:String = null;
         var rewardUrl:String = LimboInnovationManager.getInstance().getRewardUrl(this.m_buildingId);
         if(rewardUrl)
         {
            if(m_window[this.REWARD_MC].hasOwnProperty("icon_mc"))
            {
               this.m_objectPreviewFrame = getWidget(m_window[this.REWARD_MC].icon_mc) as ResourcePreviewFrame;
               if(this.m_objectPreviewFrame)
               {
                  removeWidget(this.m_objectPreviewFrame);
               }
               urlsplit = rewardUrl.substring(rewardUrl.lastIndexOf("/") + 1).split(".");
               exportedName = urlsplit[0];
               this.m_objectPreviewFrame = new ResourcePreviewFrame(m_window[this.REWARD_MC].icon_mc,rewardUrl,exportedName);
               addWidget(this.m_objectPreviewFrame,true);
            }
         }
      }
      
      private function get buildingName() : String
      {
         return LimboInnovationManager.getInstance().getBuildingFriendlyName(this.m_buildingId);
      }
      
      private function get rewardName() : String
      {
         return LimboInnovationManager.getInstance().getRewardFriendlyName(this.m_buildingId);
      }
      
      private function onAccept(event:Event) : void
      {
         this.close();
      }
      
      override public function close() : void
      {
         super.close();
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
      }
   }
}

