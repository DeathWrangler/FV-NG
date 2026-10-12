package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.WanderingPirateManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.WanderingPirateWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class WanderingPirateKeyBoxSlot extends ZwSlotFrame
   {
      
      protected var m_owner:DisplayObject;
      
      private var m_viewButton:FarmAnimatedTextButton = null;
      
      private var m_rubiesCountTxt:ZwTextField;
      
      protected var m_data:Object;
      
      private var m_keyBoxClickView:ZwWidget;
      
      private var m_progressBarMc:ZwWidget;
      
      private var m_checkMark:ZwWidget;
      
      private var m_lock:ZwWidget;
      
      private var m_lockText:ZwTextField;
      
      public function WanderingPirateKeyBoxSlot(element:DisplayObject, owner:DisplayObject)
      {
         super(element);
         this.m_owner = owner;
         if(m_element.hasOwnProperty("view_bt"))
         {
            addWidget(this.m_viewButton = new FarmAnimatedTextButton(m_element.view_bt,ZLocUtils.t("Dialogs",WanderingPirateManager.FEATURE_NAME + "_viewButtonText"),this.onViewButtonClicked)) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("rubyCount_txt"))
         {
            this.m_rubiesCountTxt = new ZwTextField(m_element.rubyCount_txt,"");
            addWidget(this.m_rubiesCountTxt);
         }
         if(m_element.hasOwnProperty("mouseOver_mc"))
         {
            this.m_keyBoxClickView = addWidget(new ZwWidget(m_element.mouseOver_mc),false) as ZwWidget;
         }
         if(m_element.hasOwnProperty("progressBar_mc"))
         {
            this.m_progressBarMc = addWidget(new ZwWidget(m_element.progressBar_mc),true) as ZwWidget;
         }
         if(m_element.hasOwnProperty("completeIcon_mc"))
         {
            this.m_checkMark = addWidget(new ZwWidget(m_element.completeIcon_mc),false) as ZwWidget;
         }
         if(m_element.hasOwnProperty("lock_mc"))
         {
            this.m_lock = addWidget(new ZwWidget(m_element.lock_mc),false) as ZwWidget;
         }
         if(m_element.hasOwnProperty("lock_tf"))
         {
            this.m_lockText = new ZwTextField(m_element.lock_tf,"Unlocks in " + (WanderingPirateManager.getInstance().getDaysRemaining() - 14) + " days");
            addWidget(this.m_lockText);
         }
      }
      
      public function onViewButtonClicked(event:Event = null) : void
      {
         if((this.m_owner as WanderingPirateWindow).m_craftFrame)
         {
            (this.m_owner as WanderingPirateWindow).toggleRewardAndCraftFrame(true);
            (this.m_owner as WanderingPirateWindow).m_rewardItemsFrame.items = this.m_data;
            (this.m_owner as WanderingPirateWindow).m_keyBoxSlotFrame.refresh();
            if(this.m_keyBoxClickView)
            {
               this.m_keyBoxClickView.visible = true;
            }
            StatsManager.count("" + WanderingPirateManager.FEATURE_NAME,"" + this.m_data["keyBoxNumber"],"viewClicked");
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         if(this.m_keyBoxClickView)
         {
            this.m_keyBoxClickView.visible = false;
         }
         if(this.m_viewButton)
         {
            this.m_viewButton.visible = true;
            this.m_viewButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",WanderingPirateManager.FEATURE_NAME + "_keyBoxToolTip",{"count":data[WanderingPirateManager.REWARD_ITEMS_STRING][WanderingPirateManager.CURRENCY_COUNT]})));
         }
         if(this.m_checkMark)
         {
            this.m_checkMark.visible = false;
         }
         if(this.m_rubiesCountTxt)
         {
            this.m_rubiesCountTxt.visible = true;
            this.m_rubiesCountTxt.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WanderingPirateManager.FEATURE_NAME + "_chest_" + this.m_data["keyBoxNumber"]);
            this.m_rubiesCountTxt.selectable = false;
         }
         if(this.m_progressBarMc)
         {
            this.m_progressBarMc.visible = true;
            switch(this.m_data["numItemsWon"])
            {
               case 1:
                  this.m_progressBarMc.element.gotoAndPlay(2);
                  break;
               case 2:
                  this.m_progressBarMc.element.gotoAndPlay(16);
                  break;
               case 3:
                  this.m_progressBarMc.element.gotoAndPlay(31);
                  break;
               case 4:
                  this.m_progressBarMc.element.gotoAndPlay(46);
                  if(Boolean(this.m_checkMark) && !this.m_data["grantedAll"])
                  {
                     this.m_checkMark.visible = true;
                  }
            }
         }
      }
      
      override public function release() : void
      {
         this.m_viewButton.detachTooltip();
         this.m_viewButton = null;
         this.m_keyBoxClickView = null;
         this.m_rubiesCountTxt = null;
         super.release();
      }
   }
}

