package Widgets.Slots.BeatExpansion
{
   import Classes.BeatExpansionTaskDefinition;
   import Classes.util.ZLocUtils;
   import Managers.BeatExpansion.BeatExpansionBaseManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   import flash.display.DisplayObject;
   
   public class BeatExpansionSlot extends ZwFrame
   {
      
      private var m_beatManager:BeatExpansionBaseManager;
      
      private var m_parentWindow:BeatExpansionWindow;
      
      private var m_progressBar:FarmProgressBar;
      
      private var m_checkMark:ZwBaseWidget;
      
      private var m_rewardIcon:FarmIcon;
      
      private var m_lock:ZwBaseWidget;
      
      public function BeatExpansionSlot(element:DisplayObject, beatManager:BeatExpansionBaseManager, parentWindow:BeatExpansionWindow, task:BeatExpansionTaskDefinition)
      {
         super(element);
         this.m_beatManager = beatManager;
         this.m_parentWindow = parentWindow;
         addWidget(new ZwTextField(m_element.title_tf,ZLocUtils.t("Dialogs",this.m_beatManager.localizationPrefix + task.name + "_text")));
         addWidget(new FarmAnimatedTextButton(m_element.start_bt,ZLocUtils.t("Dialogs",this.m_beatManager.localizationPrefix + task.name + "_btnText"),this.generateActionCallback(task.action,task.args)));
         addWidget(new FarmIcon(m_element.icon_mc,task.imageUrl));
         this.m_progressBar = addWidget(new FarmProgressBar(m_element.meter_mc)) as FarmProgressBar;
         this.m_checkMark = addWidget(new ZwBaseWidget(m_element.check_mc),false);
         this.m_lock = addWidget(new ZwBaseWidget(m_element.lock_mc),false);
         this.m_rewardIcon = addWidget(new FarmIcon(m_element.prize_mc,task.rewardUrl),false) as FarmIcon;
         this.m_rewardIcon.setSmoothing(true);
         this.m_rewardIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",this.m_beatManager.localizationPrefix + task.name + "_reward")));
         this.setProgressAndPurchaseButton(task);
      }
      
      public function setProgressAndPurchaseButton(task:BeatExpansionTaskDefinition) : void
      {
         removeWidget(m_element.unlock_bt);
         removeWidget(m_element.coin_bt);
         if(task.progress >= task.total)
         {
            this.m_progressBar.visible = false;
            this.m_checkMark.visible = true;
            this.m_lock.visible = false;
            this.m_rewardIcon.visible = false;
         }
         else
         {
            this.m_progressBar.progress = task.progress / task.total * 100;
            this.m_progressBar.visible = true;
            this.m_lock.visible = true;
            this.m_rewardIcon.visible = true;
            if(task.purchase)
            {
               if(task.currency == BeatExpansionBaseManager.CURRENCY_CASH)
               {
                  addWidget(new FarmAnimatedCashButton(m_element.unlock_bt,ZLocUtils.t("Dialogs",this.m_beatManager.localizationPrefix + task.name + "_cashText"),task.price.toString(),this.generatePurchaseCallback(task.purchase,task.currency,task.price,task.args)));
               }
               else
               {
                  addWidget(new FarmAnimatedCashButton(m_element.coin_bt,ZLocUtils.t("Dialogs",this.m_beatManager.localizationPrefix + task.name + "_coinText"),task.price.toString(),this.generatePurchaseCallback(task.purchase,task.currency,task.price,task.args)));
               }
            }
            getWidget(m_element.start_bt).visible = task.butVisible;
         }
      }
      
      private function generateActionCallback(actionType:String, actionArgs:Array) : Function
      {
         return function():void
         {
            if(actionType == BeatExpansionBaseManager.ACTION_OPEN_MASTERY)
            {
               m_parentWindow.showMasteryFrame(actionArgs);
            }
            else
            {
               m_beatManager.executeExternalAction(actionType,actionArgs);
               m_parentWindow.close();
            }
         };
      }
      
      private function generatePurchaseCallback(purchase:String, currency:String, price:int, args:Array) : Function
      {
         return function():void
         {
            m_parentWindow.hide();
            m_beatManager.askPurchase(purchase,price,currency,args,onPurchaseAcceptOrDeny);
         };
      }
      
      private function onPurchaseAcceptOrDeny(accepted:Boolean) : void
      {
         if(this.m_parentWindow)
         {
            if(accepted)
            {
               this.m_parentWindow.refreshData();
            }
            this.m_parentWindow.show();
         }
      }
      
      override public function release() : void
      {
         this.m_checkMark = null;
         this.m_lock = null;
         this.m_parentWindow = null;
         this.m_progressBar = null;
         this.m_rewardIcon = null;
         super.release();
      }
   }
}

