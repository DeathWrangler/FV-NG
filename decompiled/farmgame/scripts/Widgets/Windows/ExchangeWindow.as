package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ExchangeSystemObject;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.DynamicObjectEvent;
   import Managers.ExchangeManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.ExchangeSlot;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ExchangeWindow extends FarmWindowWithTutorial
   {
      
      private static var m_manager:ExchangeManager = null;
      
      private var m_featureName:String = "";
      
      public function ExchangeWindow(featureName:String)
      {
         this.m_featureName = featureName;
         m_manager = ExchangeManager.getInstance();
         m_manager.addEventListener(ExchangeManager.UPDATE_EVENT,this.updateEventCallback);
         super(this.m_featureName,"assets/dialogs/FV_bushelswap.swf");
      }
      
      private function updateEventCallback(event:DynamicObjectEvent) : void
      {
         this.refreshWindow();
      }
      
      override public function refreshWindow() : void
      {
         var actionButton:FarmAnimatedTextButton = null;
         var actionText:String = null;
         var actionCallback:Function = null;
         var systemObject:ExchangeSystemObject = null;
         var iconUrl:String = null;
         var bushelName:String = null;
         super.refreshWindow();
         var inputsReady:Boolean = m_manager.getTradeInNumberNeeded(this.m_featureName) == 0;
         var output:String = m_manager.getOutputItem(this.m_featureName);
         var outputItem:FarmItem = null;
         if(output != null)
         {
            outputItem = Global.farmGameSettingsManager.getFarmItemByName(output);
         }
         if(m_window.input_tf != null)
         {
            getWidget(m_window.input_tf).visible = !inputsReady;
         }
         if(m_window.check_mc != null)
         {
            getWidget(m_window.check_mc).visible = inputsReady;
         }
         if(m_window.check2_mc != null)
         {
            getWidget(m_window.check2_mc).visible = outputItem != null;
         }
         if(m_window.groupbushel_mc != null)
         {
            getWidget(m_window.groupbushel_mc).visible = !inputsReady;
         }
         if(m_window.singlebushel_mc != null)
         {
            getWidget(m_window.singlebushel_mc).visible = inputsReady && outputItem == null;
         }
         if(m_window.output_tf != null)
         {
            getWidget(m_window.output_tf).visible = inputsReady && outputItem == null;
         }
         if(m_window.trademessage_tf != null)
         {
            getWidget(m_window.trademessage_tf).visible = inputsReady && outputItem != null;
         }
         if(m_window.trade_bt != null)
         {
            actionButton = getWidget(m_window.trade_bt) as FarmAnimatedTextButton;
            actionText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeAdd");
            actionCallback = this.addCallback;
            if(inputsReady && outputItem == null)
            {
               actionText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelect");
               actionCallback = this.selectCallback;
            }
            else if(inputsReady && outputItem != null)
            {
               actionText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeTradeButton");
               actionCallback = this.tradeCallback;
            }
            actionButton.text = actionText;
            actionButton.callback = actionCallback;
            systemObject = m_manager.getExchangeSystemObject(this.m_featureName);
            actionButton.toggleClickableButton(systemObject.hasAvailableSlot());
         }
         if(m_window.add_bt != null)
         {
            getWidget(m_window.add_bt).visible = inputsReady;
         }
         if(m_window.select_bt != null)
         {
            getWidget(m_window.select_bt).visible = outputItem != null;
         }
         if(m_window.bushelicon_mc != null)
         {
            iconUrl = null;
            if(outputItem != null)
            {
               iconUrl = outputItem.icon;
               (getWidget(m_window.bushelicon_mc) as FarmIcon).loadIcon(iconUrl);
            }
         }
         if(m_window.bushelname_tf != null)
         {
            bushelName = "";
            if(outputItem != null)
            {
               bushelName = outputItem.friendlyTitle;
               (getWidget(m_window.bushelname_tf) as ZwTextField).text = bushelName;
            }
         }
         if(m_window.progess_mc != null)
         {
            (getWidget(m_window.progess_mc) as GenericSlotContainerFrame).refresh();
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var buttonText:String = null;
         var callback:Function = null;
         var actionButton:FarmAnimatedTextButton = null;
         var systemObject:ExchangeSystemObject = null;
         var iconUrl:String = null;
         var bushelName:String = null;
         var ovenCount:int = 0;
         var slotNumData:Array = null;
         var slotNum:int = 0;
         super.postLoadComplete();
         if(m_window.title_tf != null)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeTitle")));
         }
         if(m_window.sub_tf != null)
         {
            addWidget(new ZwTextField(m_window.sub_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSubtitle")));
         }
         var inputsReady:Boolean = m_manager.getTradeInNumberNeeded(this.m_featureName) == 0;
         var output:String = m_manager.getOutputItem(this.m_featureName);
         var outputItem:FarmItem = null;
         if(output != "")
         {
            outputItem = Global.farmGameSettingsManager.getFarmItemByName(output);
         }
         var totalInputs:int = m_manager.getTradeInTotalNumberNeeded(this.m_featureName);
         if(m_window.input_tf != null)
         {
            addWidget(new ZwTextField(m_window.input_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeInput",{"quantity":totalInputs})),!inputsReady);
         }
         if(m_window.output_tf != null)
         {
            addWidget(new ZwTextField(m_window.output_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeOutput")),inputsReady && outputItem == null);
         }
         if(m_window.trademessage_tf != null)
         {
            addWidget(new ZwTextField(m_window.trademessage_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeTrade",{"quantity":totalInputs})),inputsReady && outputItem != null);
         }
         if(m_window.trade_bt != null)
         {
            buttonText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeAdd");
            callback = this.addCallback;
            if(inputsReady && outputItem == null)
            {
               buttonText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelect");
               callback = this.selectCallback;
            }
            else if(inputsReady && outputItem != null)
            {
               buttonText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeTradeButton");
               callback = this.tradeCallback;
            }
            actionButton = addWidget(new FarmAnimatedTextButton(m_window.trade_bt,buttonText,callback)) as FarmAnimatedTextButton;
            systemObject = m_manager.getExchangeSystemObject(this.m_featureName);
            actionButton.toggleClickableButton(systemObject.hasAvailableSlot());
         }
         if(m_window.check_mc != null)
         {
            addWidget(new ZwWidget(m_window.check_mc),inputsReady);
         }
         if(m_window.check2_mc != null)
         {
            addWidget(new ZwWidget(m_window.check2_mc),outputItem != null);
         }
         if(m_window.groupbushel_mc != null)
         {
            addWidget(new ZwWidget(m_window.groupbushel_mc),!inputsReady);
         }
         if(m_window.singlebushel_mc != null)
         {
            addWidget(new ZwWidget(m_window.singlebushel_mc),inputsReady && outputItem == null);
         }
         if(m_window.add_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_window.add_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeAddEdit"),this.addCallback),inputsReady);
         }
         if(m_window.select_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_window.select_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeSelectEdit"),this.selectCallback),outputItem != null);
         }
         if(m_window.bushelicon_mc != null)
         {
            iconUrl = null;
            if(outputItem != null)
            {
               iconUrl = outputItem.icon;
            }
            addWidget(new FarmIcon(m_window.bushelicon_mc,iconUrl));
         }
         if(m_window.bushelname_tf != null)
         {
            bushelName = "";
            if(outputItem != null)
            {
               bushelName = outputItem.friendlyTitle;
            }
            addWidget(new ZwTextField(m_window.bushelname_tf,bushelName));
         }
         if(m_window.howDoes_mc != null)
         {
            addWidget(new FarmAnimatedButton(m_window.howDoes_mc,this.showWhatIsThis));
         }
         if(m_window.progess_mc != null)
         {
            ovenCount = m_manager.getOvenCount(this.m_featureName);
            slotNumData = new Array();
            for(slotNum = 0; slotNum < ovenCount; slotNum++)
            {
               slotNumData.push({"slotNumber":slotNum});
            }
            addWidget(new GenericSlotContainerFrame(m_window.progess_mc,ExchangeSlot,slotNumData,this));
            if(m_window.progess_mc.trade_tf != null)
            {
               addWidget(new ZwTextField(m_window.progess_mc.trade_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "ExchangeTradeProgress")));
            }
         }
      }
      
      private function addCallback(event:MouseEvent) : void
      {
         UI.displayPopup(new ExchangeSelectorWindow(this.m_featureName,ExchangeManager.ADD_STATE),false,this.m_featureName + "ExchangeAddWindow",true);
         (getWidget(m_window.trade_bt) as FarmAnimatedTextButton).toggleClickableButton(false);
      }
      
      private function selectCallback(event:MouseEvent) : void
      {
         UI.displayPopup(new ExchangeSelectorWindow(this.m_featureName,ExchangeManager.SELECT_STATE),false,this.m_featureName + "ExchangeSelectWindow",true);
         (getWidget(m_window.trade_bt) as FarmAnimatedTextButton).toggleClickableButton(false);
      }
      
      private function tradeCallback(event:MouseEvent) : void
      {
         m_manager.startTrade(this.m_featureName);
         this.refreshWindow();
      }
      
      private function showWhatIsThis(event:MouseEvent) : void
      {
         showTutorial();
      }
      
      public function getFeatureName() : String
      {
         return this.m_featureName;
      }
      
      override protected function release() : void
      {
         m_manager.removeEventListener(ExchangeManager.UPDATE_EVENT,this.updateEventCallback);
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         m_manager.windowClosed(this.m_featureName);
         super.onClose(event);
      }
   }
}

