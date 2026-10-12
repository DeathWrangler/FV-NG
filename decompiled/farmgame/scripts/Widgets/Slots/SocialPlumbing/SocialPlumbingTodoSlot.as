package Widgets.Slots.SocialPlumbing
{
   import Classes.EmbeddedArt;
   import Classes.SocialPlumbing.SPPostW2WAction;
   import Classes.SocialPlumbing.SocialPlumbingAction;
   import Classes.util.ZLocUtils;
   import Events.SocialPlumbingEvent;
   import Managers.SocialPlumbingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.SocialPlumbing.SocialPlumbingTodoSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SocialPlumbingTodoSlot extends ZwSlotFrame
   {
      
      protected static const NUM_SLOT_ITEMS:int = 6;
      
      protected static const DEFAULT_ICON_HEIGHT:int = 50;
      
      protected static const DEFAULT_ICON_WIDTH:int = 50;
      
      protected var m_plumbingAction:SocialPlumbingAction = null;
      
      protected var m_parentSlotFrame:SocialPlumbingTodoSlotFrame = null;
      
      public function SocialPlumbingTodoSlot(element:DisplayObject, parentSlotFrame:SocialPlumbingTodoSlotFrame)
      {
         this.m_parentSlotFrame = parentSlotFrame;
         super(element);
         addWidget(new ZwTextField(m_element.task_tf));
         addWidget(new ZwTextField(m_element.friendHelped_tf));
         addWidget(new ZwWidget(m_element.pointer_mc));
         addWidget(new ZwWidget(m_element.checkMark_mc));
         addWidget(new FarmAnimatedTextButton(m_element.helpOut_bt,ZLocUtils.t("Dialogs","SocialPlumbingTodoHelpButton"),this.onHelpOutButton));
         addWidget(new FarmIcon(m_element.friendPic_mc));
      }
      
      protected function onHelpOutButton(event:MouseEvent) : void
      {
         var helpButton:FarmAnimatedTextButton = getWidget(m_element.helpOut_bt) as FarmAnimatedTextButton;
         helpButton.enabled = false;
         var socialActionTask:ZwTextField = getWidget(m_element.task_tf) as ZwTextField;
         var gender:String = this.m_plumbingAction.friend.snUser.gender;
         socialActionTask.text = ZLocUtils.t("Dialogs","SocialPlumbingTodoTaskProgress",{"user":ZLocUtils.tn(this.m_plumbingAction.friend.name,ZLocUtils.tg(gender))});
         this.m_parentSlotFrame.toggleMainWindow(false);
         this.addFeedListeners();
         this.m_plumbingAction.takeAction();
         if(this.m_plumbingAction.shouldForceClose())
         {
            this.m_parentSlotFrame.closeMainWindow();
         }
      }
      
      protected function addFeedListeners() : void
      {
         if(this.m_plumbingAction is SPPostW2WAction)
         {
            this.m_plumbingAction.addEventListener(SocialPlumbingEvent.FEED_ACCEPT,this.onFeedItem);
            this.m_plumbingAction.addEventListener(SocialPlumbingEvent.FEED_CLOSED,this.onFeedItem);
            this.m_plumbingAction.addEventListener(SocialPlumbingEvent.FEED_SKIPPED,this.onFeedItem);
         }
      }
      
      protected function removeFeedListeners() : void
      {
         if(this.m_plumbingAction is SPPostW2WAction)
         {
            this.m_plumbingAction.removeEventListener(SocialPlumbingEvent.FEED_ACCEPT,this.onFeedItem);
            this.m_plumbingAction.removeEventListener(SocialPlumbingEvent.FEED_CLOSED,this.onFeedItem);
            this.m_plumbingAction.removeEventListener(SocialPlumbingEvent.FEED_SKIPPED,this.onFeedItem);
         }
      }
      
      protected function onFeedItem(event:Event = null) : void
      {
         this.removeFeedListeners();
         this.m_parentSlotFrame.toggleMainWindow(true);
         var postedFeed:Boolean = false;
         if(event.type == SocialPlumbingEvent.FEED_ACCEPT)
         {
            postedFeed = true;
         }
         var className:String = SocialPlumbingAction.getServerClassNameFromAction(this.m_plumbingAction);
         SocialPlumbingManager.getInstance().updateCompletedTask(className,this.m_plumbingAction.friendUid,postedFeed);
         this.m_parentSlotFrame.refreshMainWindow();
         this.populate(this.m_plumbingAction);
      }
      
      override public function populate(data:Object) : void
      {
         var pic:DisplayObject = null;
         var icon:Object = null;
         super.populate(data);
         this.m_plumbingAction = data as SocialPlumbingAction;
         var socialActionTask:ZwTextField = getWidget(m_element.task_tf) as ZwTextField;
         socialActionTask.text = this.m_plumbingAction.messageText;
         var completedText:ZwTextField = getWidget(m_element.friendHelped_tf) as ZwTextField;
         completedText.text = ZLocUtils.t("Dialogs","SocialPlumbingTodoFinishTask");
         var checkMark_mc:ZwWidget = getWidget(m_element.checkMark_mc) as ZwWidget;
         var helpButton:FarmAnimatedTextButton = getWidget(m_element.helpOut_bt) as FarmAnimatedTextButton;
         helpButton.text = this.m_plumbingAction.acceptButtonText;
         var pointerBg:ZwWidget = getWidget(m_element.pointer_mc) as ZwWidget;
         pointerBg.visible = true;
         if(this.m_plumbingAction.isComplete)
         {
            checkMark_mc.visible = true;
            completedText.visible = true;
            helpButton.visible = false;
            socialActionTask.visible = false;
         }
         else
         {
            checkMark_mc.visible = false;
            completedText.visible = false;
            helpButton.visible = true;
            socialActionTask.visible = true;
         }
         var itemIcon:FarmIcon = getWidget(m_element.friendPic_mc) as FarmIcon;
         if(this.m_plumbingAction.friend.snUser.picture)
         {
            itemIcon.loadIcon(this.m_plumbingAction.friend.snUser.picture);
         }
         else
         {
            pic = new EmbeddedArt.hud_no_profile_pic();
            pic.width = DEFAULT_ICON_WIDTH;
            pic.height = DEFAULT_ICON_HEIGHT;
            m_element.friendPic_mc.addChild(pic);
            icon = new EmbeddedArt.hud_no_profile_pic();
         }
         itemIcon.visible = true;
         itemIcon.detachTooltip();
         itemIcon.attachTooltip(new FarmTextTooltip(this.m_plumbingAction.friend.name));
         itemIcon.setIconSize(DEFAULT_ICON_WIDTH,DEFAULT_ICON_HEIGHT);
      }
   }
}

