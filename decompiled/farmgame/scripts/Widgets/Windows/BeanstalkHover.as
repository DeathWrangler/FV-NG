package Widgets.Windows
{
   import Classes.Friend;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Managers.BeanstalkHoverManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Windows.ZwAbstractWindow;
   import Widgets.Icons.FarmIcon;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class BeanstalkHover extends ZwAbstractWindow
   {
      
      public static const TYPE_STATUS:String = "beanstalk_marker";
      
      public static const TYPE_FRIEND:String = "beanstalk_friend";
      
      private const FRIEND_HOVER_ASSET_URL:String = "assets/hud/FV_Hud_3Friends2.swf";
      
      private const STATUS_HOVER_ASSET_URL:String = "assets/hud/FV_HUD_StatusArrow2.swf";
      
      private const STATUS_X_OFFSET_RATIO:Number = 0.75;
      
      private const MAXFRIENDSLOTS:int = 3;
      
      private var m_hoverType:String = "";
      
      private var m_currentTf:ZwTextField = null;
      
      private var m_nextGoalTf:ZwTextField = null;
      
      private var m_nextGoalLabelTf:ZwTextField = null;
      
      private var m_highscoreTf:ZwTextField = null;
      
      private var m_regrowMc:ZwFrame = null;
      
      private var m_regrowTf:ZwTextField = null;
      
      private var m_regrowBtn:FarmAnimatedCashButton = null;
      
      private var m_manager:BeanstalkHoverManager = null;
      
      public function BeanstalkHover(type:String = "beanstalk_marker", manager:BeanstalkHoverManager = null)
      {
         this.m_hoverType = type;
         this.m_manager = manager;
         var path:String = "";
         switch(this.m_hoverType)
         {
            case TYPE_FRIEND:
               path = this.FRIEND_HOVER_ASSET_URL;
               break;
            case TYPE_STATUS:
            default:
               path = this.STATUS_HOVER_ASSET_URL;
         }
         super(Global.getAssetURL(path));
      }
      
      override protected function postLoadComplete() : void
      {
         var swfRegrowMc:MovieClip = null;
         super.postLoadComplete();
         if(this.m_hoverType == TYPE_STATUS)
         {
            this.m_currentTf = new ZwTextField(m_window.progressArrow_mc.arrow_mc.number0_tf,"");
            this.m_nextGoalTf = new ZwTextField(m_window.progressArrow_mc.arrow_mc.number1_tf,"");
            this.m_nextGoalLabelTf = new ZwTextField(m_window.progressArrow_mc.arrow_mc.generic1_tf,"Next Goal:");
            this.m_highscoreTf = new ZwTextField(m_window.progressArrow_mc.arrow_mc.number2_tf,"");
            if(m_window.progressArrow_mc.arrow_mc.hasOwnProperty("regrow_mc"))
            {
               swfRegrowMc = m_window.progressArrow_mc.arrow_mc.regrow_mc;
               this.m_regrowMc = new ZwFrame(swfRegrowMc);
               this.m_regrowMc.addWidget(this.m_regrowTf = new ZwTextField(swfRegrowMc.generic_tf,ZLocUtils.t("Dialogs","Retention_Beanstalk_RegrowArrow",{"height":this.m_manager.getRegrowHeight()})));
               this.m_regrowMc.addWidget(this.m_regrowBtn = new FarmAnimatedCashButton(swfRegrowMc.regrow_bt,ZLocUtils.t("Dialogs","Retention_Beanstalk_Regrow"),this.m_manager.getRegrowPrice().toString(),this.onHoverRegrow));
               addWidget(this.m_regrowMc);
            }
            addWidget(new ZwBaseWidget(m_window.progressArrow_mc));
            addWidget(this.m_currentTf);
            addWidget(this.m_nextGoalTf);
            addWidget(this.m_highscoreTf);
            addWidget(new FarmAnimatedButton(m_window.progressArrow_mc.arrow_mc.whatisthis_mc,this.showWhatIsThisDialog));
         }
      }
      
      override protected function createLoader(url:String, onLoadCallback:Function) : Loader
      {
         return LoadingManager.load(url,onLoadCallback,LoadingManager.PRIORITY_HIGH);
      }
      
      public function update(beanstalkPos:Point, yOffset:int = 0, xOffset:int = 0) : void
      {
         if(this.m_hoverType == TYPE_STATUS)
         {
            this.x = beanstalkPos.x + xOffset * this.STATUS_X_OFFSET_RATIO;
            this.y = beanstalkPos.y + yOffset - this.height / 2;
         }
         else
         {
            this.x = beanstalkPos.x + xOffset - m_window.width / 2;
            this.y = beanstalkPos.y + yOffset;
         }
      }
      
      public function updateStatus(current:int, nextGoal:int, highscore:int, shouldShowWitherRetore:Boolean) : void
      {
         this.m_currentTf.text = current.toString() + ZLocUtils.t("Dialogs","Retention_beanstalk_height_units");
         if(nextGoal >= 0)
         {
            this.m_nextGoalTf.text = nextGoal.toString() + ZLocUtils.t("Dialogs","Retention_beanstalk_height_units");
         }
         else
         {
            this.m_nextGoalLabelTf.text = ZLocUtils.t("Dialogs","Retention_beanstalk_max_height");
            this.m_nextGoalTf.text = "";
         }
         this.m_highscoreTf.text = highscore.toString() + ZLocUtils.t("Dialogs","Retention_beanstalk_height_units");
         if(this.m_regrowTf != null && this.m_regrowBtn != null)
         {
            this.m_regrowTf.text = ZLocUtils.t("Dialogs","Retention_Beanstalk_RegrowArrow",{"height":this.m_manager.getRegrowHeight()});
            this.m_regrowBtn.setAmountText(this.m_manager.getRegrowPrice().toString());
         }
         this.m_regrowMc.visible = shouldShowWitherRetore;
      }
      
      public function updateFriend(friends:Array) : Boolean
      {
         var numFriends:int = 0;
         var leaderboardPosition:int = 0;
         var i:int = 0;
         var friendMc:MovieClip = null;
         var friendFrame:ZwFrame = null;
         var uid:String = null;
         var friendData:Friend = null;
         var name:String = null;
         var updated:Boolean = false;
         this.visible = false;
         if(friends != null && friends.length > 0)
         {
            numFriends = int(friends.length);
            leaderboardPosition = 0;
            i = 0;
            while(leaderboardPosition < this.MAXFRIENDSLOTS && i < numFriends)
            {
               friendMc = m_window["friend" + leaderboardPosition + "_mc"];
               if(!friendMc)
               {
                  break;
               }
               if(numFriends > i)
               {
                  friendFrame = new ZwFrame(friendMc);
                  uid = friends[i]["uid"];
                  if(uid != "0")
                  {
                     friendData = Global.friendManager.getFriendData(uid);
                     if(friendData)
                     {
                        name = friendData.firstName;
                        friendFrame.addWidget(new ZwTextField(friendMc.name2_tf,name));
                        friendFrame.addWidget(new ZwTextField(friendMc.number2_tf,friends[i]["value"] + ZLocUtils.t("Dialogs","Retention_beanstalk_height_units")));
                        friendFrame.addWidget(new FarmIcon(friendMc.icon2_mc,FarmGameUtil.getFriendIconByUid(uid)));
                        friendFrame.visible = true;
                        leaderboardPosition++;
                     }
                  }
               }
               else
               {
                  friendMc.visible = false;
               }
               i++;
            }
            updated = true;
            this.visible = true;
         }
         return updated;
      }
      
      private function showWhatIsThisDialog(event:MouseEvent) : void
      {
         UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","Retention_Beanstalk_WhatIsThis")));
      }
      
      private function onHoverRegrow(event:MouseEvent) : void
      {
         FarmStatsManager.featureSample(BeanstalkHoverManager.BEANSTALK_STATS_KINGDOM,"regrow","hover",this.m_manager.getRegrowHeight().toString(),this.m_manager.getRegrowPrice().toString());
         this.m_manager.showRegrowConfirmation();
      }
   }
}

