package Widgets.Windows.SocialPlumbing
{
   import Classes.SocialPlumbing.SocialPlumbingAction;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.SocialPlumbingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.SocialPlumbing.SocialPlumbingTodoSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class SocialPlumbingTodoList extends FarmWindow
   {
      
      protected static const POPUP_NAME:String = "socialPlumbingTodoListPopup";
      
      protected var DIALOG_ASSET:String = "assets/dialogs/socialPlumbing_v3.swf";
      
      protected var m_slotFrame:SocialPlumbingTodoSlotFrame = null;
      
      public function SocialPlumbingTodoList()
      {
         super(this.DIALOG_ASSET);
         this.name = POPUP_NAME;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwFrame(m_window.taskList_mc));
         addWidget(new ZwWidget(m_window.headerGraphic_mc));
         addWidget(new ZwWidget(m_window.counter_mc));
         addWidget(new ZwTextField(m_window.title_tf));
         addWidget(new ZwTextField(m_window.counter_mc.generic_tf));
         addWidget(new ZwWidget(m_window.counter_mc.digitThousands_mc));
         addWidget(new ZwWidget(m_window.counter_mc.digitHundreds_mc));
         addWidget(new ZwWidget(m_window.counter_mc.digitTens_mc));
         addWidget(new ZwWidget(m_window.counter_mc.digitOnes_mc));
         addWidget(new FarmAnimatedTextButton(m_window.return_bt,ZLocUtils.t("Dialogs","SocialPlumbingTodoReturnButton"),this.onClose));
         SocialPlumbingManager.getInstance().logDisplayedList();
         this.populateDataFields();
         this.onLoadSocialActionData(null);
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(SocialPlumbingManager.MAIN_STATS_COUNTER,"to_do_list_close",SocialPlumbingManager.getInstance().getNumIncompleteActions().toString());
         super.onClose(event);
      }
      
      public function populateDataFields() : void
      {
         var numFriendsHelped:Number = NaN;
         var hundredsPlace:ZwWidget = null;
         var titleHeader:ZwTextField = getWidget(m_window.title_tf) as ZwTextField;
         titleHeader.visible = true;
         var numIncompleteActions:Number = SocialPlumbingManager.getInstance().getNumIncompleteActions();
         if(numIncompleteActions > 1)
         {
            titleHeader.text = ZLocUtils.t("Dialogs","SocialPlumbingTodoTitle",{"quantity":numIncompleteActions.toString()});
         }
         else if(numIncompleteActions == 1)
         {
            titleHeader.text = ZLocUtils.t("Dialogs","SocialPlumbingTodoTitleSingle");
         }
         else
         {
            titleHeader.text = ZLocUtils.t("Dialogs","SocialPlumbingTodoTitleCongrats");
         }
         var headerPic:ZwWidget = getWidget(m_window.headerGraphic_mc) as ZwWidget;
         headerPic.visible = true;
         var counterWrapper:ZwWidget = getWidget(m_window.counter_mc) as ZwWidget;
         counterWrapper.visible = true;
         var friendsHelped:ZwTextField = getWidget(m_window.counter_mc.generic_tf) as ZwTextField;
         friendsHelped.visible = true;
         numFriendsHelped = Global.player.getActionCount(SocialPlumbingAction.NUM_FRIENDS_HELPED_KEY);
         if(numFriendsHelped == 1)
         {
            friendsHelped.text = ZLocUtils.t("Dialogs","SocialPlumbingTodoFriendHelped");
         }
         else
         {
            friendsHelped.text = ZLocUtils.t("Dialogs","SocialPlumbingTodoFriendsHelped");
         }
         var thousandsPlace:ZwWidget = getWidget(m_window.counter_mc.digitThousands_mc) as ZwWidget;
         thousandsPlace.visible = true;
         thousandsPlace.element.digit_tf.text = int(numFriendsHelped / 1000);
         numFriendsHelped %= 1000;
         hundredsPlace = getWidget(m_window.counter_mc.digitHundreds_mc) as ZwWidget;
         hundredsPlace.visible = true;
         hundredsPlace.element.digit_tf.text = int(numFriendsHelped / 100);
         numFriendsHelped %= 100;
         var tensPlace:ZwWidget = getWidget(m_window.counter_mc.digitTens_mc) as ZwWidget;
         tensPlace.visible = true;
         tensPlace.element.digit_tf.text = int(numFriendsHelped / 10);
         numFriendsHelped %= 10;
         var onesPlace:ZwWidget = getWidget(m_window.counter_mc.digitOnes_mc) as ZwWidget;
         onesPlace.visible = true;
         onesPlace.element.digit_tf.text = numFriendsHelped;
      }
      
      protected function onLoadSocialActionData(event:Event = null) : void
      {
         var taskData:Array = SocialPlumbingManager.getInstance().getTaskList();
         this.m_slotFrame = new SocialPlumbingTodoSlotFrame(m_window.taskList_mc,taskData,this);
         this.m_slotFrame.setTaskData(taskData);
      }
      
      public function toggleCloseButton(enable:Boolean) : void
      {
         var returnButton:FarmAnimatedTextButton = getWidget(m_window.return_bt) as FarmAnimatedTextButton;
         returnButton.enabled = enable;
         var closeButton:ZwButton = getWidget(m_window.close_bt) as ZwButton;
         closeButton.enabled = enable;
      }
      
      public function toggleEnabled(enable:Boolean) : void
      {
         this.enableInput = enable;
      }
   }
}

