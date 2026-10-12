package Widgets.Slots
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.TemplateUIUtility;
   import Transactions.TBuyItemPutGiftbox;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.Quests.MultiStageQuests.MultiStageQuestDialog;
   import Widgets.Windows.Quests.MultiStageQuests.StageMultiCollectItemWidget;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class MultiCollectItemSlot extends ZwSlotFrame
   {
      
      private var m_dataItem:FarmItem = null;
      
      private var m_parentFrame:StageMultiCollectItemWidget = null;
      
      private var m_priceWidget:ZwBaseWidget = null;
      
      private var m_task:FarmTask = null;
      
      private var m_progress:ZwTextField = null;
      
      private var m_progressComplete:ZwFrame = null;
      
      private var m_progressCompleteText:ZwTextField = null;
      
      private var m_askForMoreBtn:FarmAnimatedTextButton = null;
      
      private var m_sendPartsBtn:FarmAnimatedTextButton = null;
      
      private var m_buyBtn:FarmAnimatedTextButton = null;
      
      private var m_taskIndex:int;
      
      private var m_stage:int;
      
      public function MultiCollectItemSlot(element:DisplayObject, task:FarmTask, parentFrame:StageMultiCollectItemWidget, taskIndex:int, stage:int)
      {
         var dooberIcon:FarmIcon = null;
         super(element);
         this.m_parentFrame = parentFrame;
         this.m_task = task;
         this.m_taskIndex = taskIndex;
         this.m_dataItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
         this.m_stage = stage;
         var titleText:ZwTextField = addWidget(new ZwTextField(m_element.itemTitle_tf,this.m_dataItem.friendlyTitle)) as ZwTextField;
         this.m_progressComplete = addWidget(new ZwFrame(m_element.completeIcon_mc)) as ZwFrame;
         this.m_progressCompleteText = addWidget(new ZwTextField(m_element.completeIcon_mc.completed_tf,ZLocUtils.t("Dialogs","GenericExpansion_completed_text"))) as ZwTextField;
         this.m_progress = addWidget(new ZwTextField(m_element.alive_tf)) as ZwTextField;
         var parentWindow:MultiStageQuestDialog = this.m_parentFrame.parentWindow as MultiStageQuestDialog;
         if(Boolean(parentWindow) && parentWindow.isTemplateUIEnabled())
         {
            TemplateUIUtility.applyTextColor(titleText,TemplateUIUtility.ESCAPADE,parentWindow.textColor);
            TemplateUIUtility.applyTextColor(this.m_progress,TemplateUIUtility.ESCAPADE,parentWindow.textColor);
         }
         this.m_askForMoreBtn = addWidget(new FarmAnimatedTextButton(m_element.getThis_bt,ZLocUtils.t("Dialogs","GenericExpansion_button_ask_for_more"),this.onAskMoreCallback)) as FarmAnimatedTextButton;
         this.m_buyBtn = addWidget(new FarmAnimatedTextButton(m_element.buy2_bt,ZLocUtils.t("Dialogs","BuyPart"),this.onBuyPartCallback)) as FarmAnimatedTextButton;
         this.m_priceWidget = addWidget(new ZwBaseWidget(m_element.fcPrice_mc)) as ZwBaseWidget;
         this.m_priceWidget.element.FCPrice_tf.text = this.m_dataItem.cash.toString();
         var iconBox:ZwFrame = addWidget(new ZwFrame(m_element.iconBox_mc)) as ZwFrame;
         var itemIcon:FarmIcon = addWidget(new FarmIcon(m_element["icon"])) as FarmIcon;
         itemIcon.loadIcon(this.m_dataItem.icon);
         itemIcon.visible = true;
         itemIcon.setIconSize(50,50);
         iconBox.visible = true;
         var tempElm:ZwBaseWidget = addWidget(new ZwBaseWidget(m_element.present_bt));
         tempElm.visible = false;
         tempElm = addWidget(new ZwBaseWidget(m_element.completeNow_bt));
         tempElm.visible = false;
         tempElm = addWidget(new ZwBaseWidget(m_element.use_mat_bt));
         tempElm.visible = false;
         tempElm = addWidget(new ZwBaseWidget(m_element.buy_bt));
         tempElm.visible = false;
         tempElm = addWidget(new ZwBaseWidget(m_element.use_bt));
         tempElm.visible = false;
         tempElm = addWidget(new ZwBaseWidget(m_element.sendMaterials_tf));
         tempElm.visible = false;
         if(ObjectUtil.pathExists(m_element,["doober_mc","doober_container_mc"]))
         {
            dooberIcon = addWidget(new FarmIcon(m_element.doober_mc.doober_container_mc.doober_item_mc)) as FarmIcon;
            dooberIcon.loadIcon(this.m_dataItem.icon);
            dooberIcon.visible = true;
            dooberIcon.setIconSize(50,50);
            addWidget(new FarmTextField(m_element.doober_mc.doober_container_mc.doober_tf,this.m_dataItem.friendlyTitle));
         }
         this.refresh();
      }
      
      override public function release() : void
      {
         super.release();
         this.m_dataItem = null;
         this.m_parentFrame = null;
         this.m_priceWidget = null;
         this.m_task = null;
         this.m_progress = null;
         this.m_progressComplete = null;
         this.m_askForMoreBtn = null;
         this.m_sendPartsBtn = null;
         this.m_buyBtn = null;
      }
      
      protected function refresh(resultData:Boolean = false) : void
      {
         this.m_progress.text = this.m_task.progress.toString() + " of " + this.m_task.total.toString();
         if(this.m_task.isComplete())
         {
            this.m_progressComplete.visible = true;
            this.m_progressCompleteText.visible = true;
            this.m_askForMoreBtn.visible = false;
            this.m_buyBtn.visible = false;
            this.m_priceWidget.visible = false;
         }
         else
         {
            this.m_askForMoreBtn.visible = true;
            this.m_askForMoreBtn.enabled = this.m_task.canAskForHelp();
            if(this.m_askForMoreBtn.enabled == true)
            {
               if(this.m_task.helperType == QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED)
               {
                  this.m_askForMoreBtn.text = ZLocUtils.t("Dialogs","GenericExpansion_button_ask_friends");
               }
               else
               {
                  this.m_askForMoreBtn.text = ZLocUtils.t("Dialogs","GenericExpansion_button_ask_for_more");
               }
            }
            else
            {
               this.m_askForMoreBtn.text = ZLocUtils.t("Dialogs","GenericExpansion_button_posted");
            }
            this.m_buyBtn.visible = true;
            this.m_priceWidget.visible = true;
            this.m_progressComplete.visible = false;
            this.m_progressCompleteText.visible = false;
         }
         if(null != this.m_parentFrame)
         {
            this.m_parentFrame.refresh();
         }
      }
      
      protected function onBuyPartCallback(event:MouseEvent) : void
      {
         var data:Object = null;
         var anchorObj:DisplayObject = null;
         var localPos:Point = null;
         var screen:Point = null;
         var message:String = null;
         var canBuy:Boolean = Global.player.canBuyCash(this.m_dataItem.cash,true);
         if(canBuy)
         {
            (m_element.doober_mc as MovieClip).gotoAndPlay(2);
            TransactionManager.addTransaction(new TBuyItemPutGiftbox(this.m_dataItem,Currency.CASH,1,false,true,this.onBuySuccess,true));
            data = new Object();
            data.allowReshopping = false;
            this.m_dataItem.onUse(0,data);
            anchorObj = m_element.iconBox_mc;
            localPos = new Point(anchorObj.x + anchorObj.width * 0.5,anchorObj.y + anchorObj.height);
            screen = anchorObj.localToGlobal(localPos);
            message = ZLocUtils.t("Dialogs","PlusOneStatusText",{"item":this.m_dataItem.friendlyTitle});
            UI.displayStatus(message,screen.x,screen.y,"",null,UI.DEFAULT_STATUS_TWEEN_DURATION,UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT,UI.DEFAULT_STATUS_TWEEN_FONT_SIZE,UI.STATUS_TWEEN_FONT_COLOR_WHITE);
            this.refresh();
         }
      }
      
      public function onBuySuccess(result:Object) : void
      {
         Global.player.removeGift(null,result.itemName);
      }
      
      protected function onAskMoreCallback(event:MouseEvent) : void
      {
         if(this.m_task.canAskForHelp())
         {
            if(this.m_task.helperType == QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED)
            {
               this.m_askForMoreBtn.enabled = false;
               this.m_askForMoreBtn.text = ZLocUtils.t("Dialogs","GenericExpansion_button_posting");
            }
            this.m_task.performHelperAction(null,this.refresh);
         }
      }
   }
}

