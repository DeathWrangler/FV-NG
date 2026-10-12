package Widgets.Slots.Breeding
{
   import Classes.EmbeddedArt;
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MutableAnimalEggSlot extends ZwSlotFrame
   {
      
      private var m_noIconImage:DisplayObject = new EmbeddedArt.hud_no_profile_pic();
      
      private var m_zyngaIconImage:DisplayObject = new EmbeddedArt.hud_zynga_profile_pic();
      
      private var m_friendName:FarmTextField = null;
      
      private var m_thankButton:FarmAnimatedTextButton = null;
      
      private var m_toolTip:FarmTextTooltip = null;
      
      private var m_friendId:String = "";
      
      public function MutableAnimalEggSlot(element:DisplayObject)
      {
         super(element);
         this.m_noIconImage.width = 50;
         this.m_noIconImage.height = 50;
         this.m_zyngaIconImage.width = 50;
         this.m_zyngaIconImage.height = 50;
         this.m_friendName = new FarmTextField(m_element.title_tf,"");
         addWidget(this.m_friendName,false);
         addWidget(new ZwWidget(m_element.loader_mc));
         this.m_thankButton = new FarmAnimatedTextButton(m_element.thank_bt,ZLocUtils.t("Dialogs","tradingpost_UI_thank_friend"),this.onThankYouClick);
         addWidget(this.m_thankButton,false);
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
                  this.m_friendName.text = friend.name;
                  this.m_friendName.visible = true;
                  this.m_thankButton.visible = true;
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
         }
         m_element.loader_mc.visible = true;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_friendName = null;
         this.m_toolTip = null;
      }
      
      private function onThankYouClick(event:MouseEvent) : void
      {
      }
   }
}

