package Widgets.Slots.BeatExpansion
{
   import Classes.BeatExpansionTaskDefinition;
   import Classes.util.ZLocUtils;
   import Managers.BeatExpansion.BeatExpansionBaseManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   import flash.display.DisplayObject;
   
   public class BeatExpansionTaskSlot extends ZwSlotFrame
   {
      
      private var m_beatManager:BeatExpansionBaseManager;
      
      private var m_parentWindow:BeatExpansionWindow;
      
      private var m_progressBar:FarmProgressBar;
      
      private var m_checkMark:ZwBaseWidget;
      
      private var m_rewardIcon:FarmIcon;
      
      private var m_lock:ZwBaseWidget;
      
      private var m_title:ZwTextField;
      
      private var m_startButton:FarmAnimatedTextButton;
      
      private var m_icon:FarmIcon;
      
      public function BeatExpansionTaskSlot(element:DisplayObject, beatManager:BeatExpansionBaseManager, parentWindow:BeatExpansionWindow)
      {
         super(element);
         this.m_beatManager = beatManager;
         this.m_parentWindow = parentWindow;
         this.m_title = addWidget(new ZwTextField(m_element.title_tf)) as ZwTextField;
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionSubTextColor(m_element.title_tf);
         }
         this.m_startButton = addWidget(new FarmAnimatedTextButton(m_element.start_bt,"",null)) as FarmAnimatedTextButton;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_progressBar = addWidget(new FarmProgressBar(m_element.meter_mc)) as FarmProgressBar;
         this.m_checkMark = addWidget(new ZwBaseWidget(m_element.check_mc),false);
         this.m_lock = addWidget(new ZwBaseWidget(m_element.lock_mc),false);
         this.m_rewardIcon = addWidget(new FarmIcon(m_element.prize_mc),false) as FarmIcon;
      }
      
      override public function populate(data:Object) : void
      {
         var task:BeatExpansionTaskDefinition = data as BeatExpansionTaskDefinition;
         this.m_title.text = ZLocUtils.t("Dialogs",this.m_beatManager.localizationPrefix + task.name + "_text");
         this.m_title.visible = true;
         this.m_startButton.text = ZLocUtils.t("Dialogs",this.m_beatManager.localizationPrefix + task.name + "_btnText");
         this.m_startButton.callback = this.generateActionCallback(task.action,task.args);
         this.m_startButton.visible = true;
         this.m_icon.loadIcon(task.imageUrl);
         this.m_icon.visible = true;
         this.m_icon.setSmoothing(true);
         this.m_rewardIcon.setSmoothing(true);
         if(this.m_rewardIcon.tooltip != null)
         {
            this.m_rewardIcon.detachTooltip();
         }
         this.m_rewardIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs",this.m_beatManager.localizationPrefix + task.name + "_reward")));
         this.m_rewardIcon.loadIcon(task.rewardUrl);
         this.m_rewardIcon.visible = true;
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

