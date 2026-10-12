package Widgets.Slots.DuckPond
{
   import Classes.EmbeddedArt;
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.DuckPond.DuckGameWindow;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DuckGameFriendSlot extends ZwSlotFrame
   {
      
      private var m_duckGameWindow:DuckGameWindow;
      
      private var m_noIconImage:DisplayObject = new EmbeddedArt.hud_no_profile_pic();
      
      private var m_zyngaIconImage:DisplayObject = new EmbeddedArt.hud_zynga_profile_pic();
      
      private var m_thankButton:FarmAnimatedTextButton = null;
      
      private var m_toolTip:FarmTextTooltip = null;
      
      private var m_friendId:String = "";
      
      public function DuckGameFriendSlot(element:DisplayObject, duckGameWindow:DuckGameWindow)
      {
         this.m_duckGameWindow = duckGameWindow;
         super(element);
         this.m_noIconImage.width = 50;
         this.m_noIconImage.height = 50;
         this.m_zyngaIconImage.width = 50;
         this.m_zyngaIconImage.height = 50;
         this.m_thankButton = new FarmAnimatedTextButton(m_element.thank_bt,ZLocUtils.t("Dialogs","DuckGame_Thank"),this.onThankClick);
         addWidget(this.m_thankButton,false);
         addWidget(new ZwWidget(m_element.loader_mc));
         this.m_toolTip = new FarmTextTooltip();
         attachTooltip(this.m_toolTip);
      }
      
      override public function populate(friendObject:Object) : void
      {
         var dispObj:DisplayObject = null;
         var friend:Friend = null;
         var url:String = null;
         var icon:Loader = null;
         this.m_friendId = friendObject.uid;
         if(m_element.loader_mc)
         {
            Utilities.removeAllChildren(m_element.loader_mc);
         }
         switch(this.m_friendId)
         {
            case "bought":
               m_element.loader_mc.addChild(this.m_zyngaIconImage);
               break;
            case "":
               m_element.loader_mc.addChild(this.m_noIconImage);
               break;
            default:
               friend = Global.friendManager.getAppFriendData(this.m_friendId);
               if(friend)
               {
                  this.m_toolTip.setText(friend.name);
                  url = friend.picture;
                  if(url)
                  {
                     icon = LoadingManager.load(url,function(event:Event):void
                     {
                        var dispObj:* = undefined;
                        if(Boolean(icon) && Boolean(icon.content))
                        {
                           dispObj = icon.content;
                           dispObj.width = 50;
                           dispObj.height = 50;
                           m_element.loader_mc.addChild(dispObj);
                        }
                     });
                  }
               }
               else
               {
                  FarmStatsManager.count("errors","duckling_game_friend_not_found",this.m_friendId);
               }
         }
         m_element.loader_mc.visible = true;
         if(this.m_duckGameWindow.friendsRequired == 0)
         {
            switch(this.m_friendId)
            {
               case "":
               case "bought":
                  this.m_thankButton.visible = false;
                  break;
               default:
                  if(this.m_duckGameWindow.rewardCode != "")
                  {
                     this.m_thankButton.visible = true;
                  }
            }
         }
         else
         {
            this.m_thankButton.visible = false;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_thankButton = null;
         this.m_toolTip = null;
      }
      
      private function onThankClick(event:MouseEvent) : void
      {
         var bundleData:Object = null;
         var messageType:String = null;
         this.m_thankButton.enabled = false;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_duckGameWindow.itemName);
         var rewardLink:String = this.m_duckGameWindow.thankYouRewardLinkHash[this.m_friendId];
         if(farmItem)
         {
            bundleData = {
               "reward_name":farmItem.friendlyName,
               "reward_link":rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardLink,
                  "src":farmItem.icon
               }]
            };
            messageType = "DuckGameFinishedThanks";
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[this.m_friendId],false);
         }
         FarmStatsManager.count("duck_pond_feature","duckling_ui_dialog","on_thank_click");
      }
   }
}

