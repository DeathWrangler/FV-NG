package Widgets.Windows
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BoatRushMilestoneRewardWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_flow:int;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_rewardImage:String = null;
      
      private var m_mainWindow:MovieClip;
      
      private var m_buildingIconMc:MovieClip;
      
      private var m_rewardIcon:FarmIcon;
      
      private var m_buildingNameTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_subTextTf:ZwTextField;
      
      private var m_acceptBt:FarmAnimatedTextButton;
      
      public function BoatRushMilestoneRewardWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, flow:int = 0, dialogBackground:String = null, rewardIcon:String = null)
      {
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_flow = flow;
         this.m_rewardImage = rewardIcon;
         super(dialogAsset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            this.m_mainWindow = m_window["mainWindow"] as MovieClip;
            if(this.m_mainWindow.hasOwnProperty("accept_bt"))
            {
               addWidget(this.m_acceptBt = new FarmAnimatedTextButton(this.m_mainWindow["accept_bt"],"",this.onAcceptBt));
               if(this.m_flow == 3 || this.m_flow == 4)
               {
                  this.m_acceptBt.text = "Okay!";
               }
               else
               {
                  this.m_acceptBt.text = "Great!";
               }
            }
            if(this.m_mainWindow.hasOwnProperty("title_tf"))
            {
               addWidget(new ZwTextField(this.m_mainWindow["title_tf"],"Build It Up is Over!"));
            }
            if(this.m_mainWindow.hasOwnProperty("body_tf"))
            {
               addWidget(this.m_bodyTf = new ZwTextField(this.m_mainWindow["body_tf"]));
               if(this.m_flow == 1)
               {
                  this.m_bodyTf.text = "You played amazingly well!";
               }
               else if(this.m_flow == 2)
               {
                  this.m_bodyTf.text = "You’ve not scored enough to be eligible for the bonus prize.";
               }
               else if(this.m_flow == 3)
               {
                  this.m_bodyTf.text = "You’ve not scored enough to be eligible for the bonus prize";
               }
               else if(this.m_flow == 4)
               {
                  this.m_bodyTf.text = "Refresh game to check your final rewards!";
               }
               this.m_bodyTf.visible = true;
            }
            if(this.m_mainWindow.hasOwnProperty("building_icon_mc"))
            {
               this.m_buildingIconMc = this.m_mainWindow["building_icon_mc"] as MovieClip;
               if(this.m_buildingIconMc.hasOwnProperty("reward_icon_mc"))
               {
                  this.m_rewardIcon = new FarmIcon(this.m_buildingIconMc["reward_icon_mc"]);
                  if(this.m_rewardImage)
                  {
                     this.m_rewardIcon.loadIcon(this.m_rewardImage);
                     this.m_rewardIcon.setIconSize(100,100);
                  }
                  else if(this.m_reward)
                  {
                     this.m_rewardIcon.loadIcon(this.m_reward.iconUrl);
                  }
                  this.m_rewardIcon.visible = true;
               }
               this.m_buildingIconMc.visible = true;
            }
            if(this.m_mainWindow.hasOwnProperty("buildinng_name_tf"))
            {
               addWidget(this.m_buildingNameTf = new ZwTextField(this.m_mainWindow["buildinng_name_tf"]));
               if(Boolean(this.m_reward) && this.m_flow == 1)
               {
                  if(this.m_reward.name == "alohanbeachhouse")
                  {
                     this.m_buildingNameTf.text = "You won an \n" + this.m_reward.friendlyTitle;
                  }
                  else
                  {
                     this.m_buildingNameTf.text = "You won a \n" + this.m_reward.friendlyTitle;
                  }
               }
               else if(Boolean(this.m_reward) && this.m_flow == 2)
               {
                  this.m_buildingNameTf.text = "You won an \n 3 " + this.m_reward.friendlyTitle;
               }
               else
               {
                  this.m_buildingNameTf.text = "You won a \nTropic Beach Hut, Alohan Beach House and Tropic Beach Villa";
               }
            }
            if(this.m_mainWindow.hasOwnProperty("congrats_msg_tf"))
            {
               addWidget(new ZwTextField(this.m_mainWindow["congrats_msg_tf"],"Congrats!"));
            }
            if(this.m_mainWindow.hasOwnProperty("endflow_tf"))
            {
               addWidget(this.m_subTextTf = new ZwTextField(this.m_mainWindow["endflow_tf"]));
               if(Boolean(this.m_reward) && this.m_flow == 1)
               {
                  this.m_subTextTf.text = "Enjoy your reward and remember to harvest it everyday for 14 days!";
               }
               else if(this.m_flow == 1)
               {
                  this.m_subTextTf.text = "Enjoy your rewards and remember to harvest it everyday for 14 days!";
               }
               else if(this.m_flow == 2)
               {
                  this.m_subTextTf.text = "But here is a small gift for your effort!";
               }
               else if(this.m_flow == 3)
               {
                  this.m_subTextTf.text = "Keep playing Farmville for more fun features and win cool rewards!";
               }
               else if(this.m_flow == 4)
               {
                  this.m_subTextTf.text = "Keep playing Farmville for more fun features and win cool rewards!";
               }
            }
            this.m_mainWindow.visible = true;
         }
      }
      
      private function onAcceptBt(e:Event) : void
      {
         super.close();
      }
   }
}

