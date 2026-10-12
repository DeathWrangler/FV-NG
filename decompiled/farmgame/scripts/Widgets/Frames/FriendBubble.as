package Widgets.Frames
{
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FriendBubble extends ZwFrame
   {
      
      protected static const PIC_WIDTH:int = 25;
      
      protected static const PIC_HEIGHT:int = 25;
      
      protected static const MAX_PICS:int = 3;
      
      protected var m_content:MovieClip;
      
      protected var m_friends:Array;
      
      protected var m_text:FarmAnimatedTextButton;
      
      protected var m_icons:Array;
      
      protected var m_textClickCallback:Function;
      
      protected var m_iconMouseCallback:Function;
      
      protected var m_chapter:int;
      
      public function FriendBubble(element:MovieClip, friends:Array, chapter:int)
      {
         var icon:FarmIcon = null;
         var text:String = null;
         super(element);
         this.m_friends = friends;
         this.m_content = element.content_mc;
         this.m_chapter = chapter;
         if(this.m_content.moreFriends_bt != null)
         {
            if(friends.length == MAX_PICS + 1)
            {
               text = ZLocUtils.t("Dialogs","FriendBubble_Singular");
            }
            else
            {
               text = ZLocUtils.t("Dialogs","FriendBubble_Plural",{"quantity":friends.length - MAX_PICS});
            }
            this.m_text = new FarmAnimatedTextButton(this.m_content.moreFriends_bt,text,this.onTextClick,false,true);
            addWidget(this.m_text);
         }
         this.m_icons = [];
         var iconNum:int = 0;
         for(iconNum = 0; iconNum < MAX_PICS; iconNum++)
         {
            if(this.m_content["slot" + iconNum + "_mc"] != null)
            {
               icon = new FarmIcon(this.m_content["slot" + iconNum + "_mc"],(friends[iconNum] as Friend).picture);
               icon.setIconWidth(PIC_WIDTH);
               icon.setIconHeight(PIC_HEIGHT);
               this.m_icons.push(icon);
               addWidget(icon);
            }
         }
      }
      
      public function setIconMouseEventCallback(func:Function) : void
      {
         var iconNum:int = 0;
         var icon:FarmIcon = null;
         if(this.m_iconMouseCallback == null)
         {
            iconNum = 0;
            for(iconNum = 0; iconNum < this.m_icons.length; iconNum++)
            {
               icon = this.m_icons[iconNum];
               icon.registerEventListener(MouseEvent.MOUSE_OVER,this.onIconMouseEvent);
               icon.registerEventListener(MouseEvent.MOUSE_OUT,this.onIconMouseEvent);
            }
         }
         this.m_iconMouseCallback = func;
      }
      
      protected function onIconMouseEvent(event:MouseEvent) : void
      {
         var iconNum:int = 0;
         for(iconNum = 0; iconNum < this.m_icons.length; iconNum++)
         {
            if(event.target == (this.m_icons[iconNum] as FarmIcon).element)
            {
               break;
            }
         }
         if(this.m_iconMouseCallback != null && iconNum < this.m_icons.length)
         {
            this.m_iconMouseCallback(this.m_friends[iconNum],event);
         }
      }
      
      public function setTextMouseClickCallback(func:Function) : void
      {
         if(this.m_text == null && this.m_textClickCallback == null && this.m_content.generic_tf != null)
         {
            this.m_text.registerEventListener(MouseEvent.CLICK,this.onTextClick);
         }
         this.m_textClickCallback = func;
      }
      
      protected function onTextClick(event:Event) : void
      {
         if(this.m_textClickCallback != null)
         {
            this.m_textClickCallback(this.m_friends,this.m_chapter);
         }
      }
   }
}

