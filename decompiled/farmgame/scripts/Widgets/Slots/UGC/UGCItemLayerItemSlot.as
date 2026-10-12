package Widgets.Slots.UGC
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.UGC.UGCConstants;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.util.ColorUtil;
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.ZwToggleSlotFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class UGCItemLayerItemSlot extends ZwToggleSlotFrame
   {
      
      private static const ICON_SCALE:Number = 0.6;
      
      protected var m_item:FarmItem;
      
      private var m_overFrame:ZwFrame;
      
      private var m_downFrame:ZwFrame;
      
      private var m_newFrame:ZwFrame;
      
      private var m_earlyFrame:ZwFrame;
      
      private var m_exclusiveFrame:ZwFrame;
      
      private var m_previewButton:FarmAnimatedTextButton;
      
      private var m_buyBt:FarmAnimatedCashButton;
      
      public function UGCItemLayerItemSlot(element:DisplayObject)
      {
         super(element);
         if(ObjectUtil.pathExists(m_element,"over_mc"))
         {
            addWidget(this.m_overFrame = new ZwFrame(m_element.over_mc),false);
            this.addRolloverListeners();
         }
         if(ObjectUtil.pathExists(m_element,"down_mc"))
         {
            addWidget(this.m_downFrame = new ZwFrame(m_element.down_mc),false);
         }
         if(ObjectUtil.pathExists(m_element,"paintIcon_mc"))
         {
            addWidget(new ZwFrame(m_element.paintIcon_mc),false);
         }
         if(ObjectUtil.pathExists(m_element,"generic_tf"))
         {
            addWidget(new ZwTextField(m_element.generic_tf),false);
         }
         if(ObjectUtil.pathExists(m_element,"icon"))
         {
            addWidget(new FarmIcon(m_element.icon),false);
         }
         if(ObjectUtil.pathExists(m_element,"iconBox_mc"))
         {
            addWidget(new ZwFrame(m_element.iconBox_mc),false);
         }
         if(ObjectUtil.pathExists(m_element,"new_mc"))
         {
            addWidget(this.m_newFrame = new ZwFrame(m_element.new_mc),false);
         }
         if(ObjectUtil.pathExists(m_element,"early_mc"))
         {
            addWidget(this.m_earlyFrame = new ZwFrame(m_element.early_mc),false);
         }
         if(ObjectUtil.pathExists(m_element,"exclusive_mc"))
         {
            addWidget(this.m_exclusiveFrame = new ZwFrame(m_element.exclusive_mc),false);
         }
         if(ObjectUtil.pathExists(m_element,"preview_bt"))
         {
            addWidget(this.m_previewButton = new FarmAnimatedTextButton(m_element.preview_bt," ",this.onPreviewClick),false);
         }
         if(ObjectUtil.pathExists(m_element,"buy_bt"))
         {
            addWidget(this.m_buyBt = new FarmAnimatedCashButton(m_element.buy_bt,"Unlock",UGCConstants.DREAM_FISH_PART_UNLOCK_PRICE.toString(),this.onBuyClick));
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_item = null;
         this.m_overFrame = null;
         this.m_downFrame = null;
      }
      
      private function addRolloverListeners() : void
      {
         registerEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         registerEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      private function removeRolloverListeners() : void
      {
         unregisterEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         unregisterEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      override protected function select() : void
      {
         this.removeRolloverListeners();
         this.onRollOut();
         if(this.m_downFrame != null)
         {
            this.m_downFrame.visible = true;
         }
      }
      
      override protected function deselect() : void
      {
         if(this.m_downFrame != null)
         {
            this.m_downFrame.visible = false;
         }
         this.addRolloverListeners();
      }
      
      override public function clearView() : void
      {
         super.clearView();
         detachTooltip();
      }
      
      override public function populate(data:Object) : void
      {
         var textField:ZwTextField = null;
         var icon:FarmIcon = null;
         var enable:Boolean = false;
         var isEAUser:Boolean = false;
         var marketPrereq:String = null;
         var startDate:String = null;
         var cashText:String = null;
         var price:Object = null;
         var string:String = null;
         var farmItem:FarmItem = null;
         var iconBox:ZwFrame = null;
         var result:Boolean = false;
         super.populate(data);
         this.m_item = data as FarmItem;
         if(this.m_item != null)
         {
            textField = getWidget("generic_tf") as ZwTextField;
            if(textField != null)
            {
               cashText = "";
               if(this.item.market == FarmItem.MARKET_CONTEXT_CASH)
               {
                  textField.text = ZLocUtils.t("Dialogs","FarmCash",{"amount":this.item.cash});
                  textField.visible = true;
               }
               else if(this.item.getMaterialPrice())
               {
                  price = this.item.getMaterialPrice();
                  var _loc14_:int = 0;
                  var _loc15_:* = price;
                  for(string in _loc15_)
                  {
                     farmItem = Global.farmGameSettingsManager.getFarmItemByName(string);
                  }
                  if(farmItem)
                  {
                     textField.text = "" + price[string] + " " + ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
                     textField.visible = true;
                  }
               }
            }
            icon = getWidget("icon") as FarmIcon;
            if(icon != null)
            {
               icon.loadIcon(this.item.iconUrl);
               icon.setIconScale(ICON_SCALE,ICON_SCALE);
               icon.setSmoothing(true);
               icon.visible = true;
               iconBox = getWidget("iconBox_mc") as ZwFrame;
               if(iconBox != null)
               {
                  iconBox.visible = true;
               }
            }
            this.deselect();
            this.enabled = true;
            this.element.filters = [];
            enable = this.item.checkPurchasePrereqs();
            if(m_element.lock_mc)
            {
               m_element.lock_mc.visible = !enable;
            }
            isEAUser = this.item.checkMarketPrereqs();
            marketPrereq = this.item.marketPrereqName;
            startDate = this.item.limitedStartDate;
            if(marketPrereq)
            {
               if(isEAUser)
               {
                  if(Boolean(startDate) && !FarmGameUtil.checkStartDateGate(UGCConstants.UNDERWATER_GA_CONTENT_DROP_DATE))
                  {
                     if(this.m_earlyFrame != null)
                     {
                        this.m_earlyFrame.visible = true;
                     }
                  }
                  else if(this.m_exclusiveFrame != null)
                  {
                     this.m_exclusiveFrame.visible = true;
                  }
               }
               else if(startDate)
               {
                  if(FarmGameUtil.checkStartDateGate(startDate))
                  {
                     if(!FarmGameUtil.checkDateGateWithRangeNumber(startDate,7))
                     {
                        if(this.m_newFrame != null)
                        {
                           this.m_newFrame.visible = true;
                        }
                     }
                     if(this.m_buyBt != null)
                     {
                        result = false;
                        if(marketPrereq)
                        {
                           result = FeatureOptionsManager.getInstance().getFeatureOption(UGCConstants.FO_AOE_LICENSE,this.item.aoeLicenseKey) as Boolean;
                           if(!result)
                           {
                              this.m_buyBt.visible = true;
                              if(this.m_previewButton != null)
                              {
                                 this.m_previewButton.visible = true;
                              }
                           }
                        }
                     }
                  }
               }
            }
            if(!enable)
            {
               attachTooltip(new FarmTextTooltip(this.getToolTip()));
               this.element.filters = [ColorUtil.getGreyscaleFilter()];
            }
            else
            {
               attachTooltip(new FarmTextTooltip(this.item.friendlyTitle));
            }
         }
      }
      
      public function get item() : FarmItem
      {
         return this.m_item;
      }
      
      private function onRollOver(event:MouseEvent = null) : void
      {
         if(this.m_overFrame != null)
         {
            this.m_overFrame.visible = true;
         }
      }
      
      private function onRollOut(event:MouseEvent = null) : void
      {
         if(this.m_overFrame != null)
         {
            this.m_overFrame.visible = false;
         }
      }
      
      protected function getToolTip() : String
      {
         var lastPreReqTested:Object = null;
         var key:String = null;
         var lastType:String = null;
         var lastContext:String = null;
         var lastValue:String = null;
         var lastQuantity:String = null;
         var message:String = null;
         var locks:Array = this.item.getLockedStates(this);
         var lock:String = "";
         for(var i:Number = 0; i < locks.length; i++)
         {
            lock = locks[i];
            switch(lock)
            {
               case FarmItemLock.PURCHASE_PREREQ:
                  lastPreReqTested = this.item.diagnoseFailedPurchasePrereqs(this);
                  if(lastPreReqTested)
                  {
                     key = "MarketCard_PrereqLocked_Rollover";
                     lastType = "";
                     lastContext = "";
                     lastValue = "";
                     lastQuantity = "";
                     if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_TYPE))
                     {
                        lastType = lastPreReqTested[PrerequisiteConstants.KEY_TYPE];
                        key += "_" + lastType;
                     }
                     if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_CONTEXT_PATH))
                     {
                        lastContext = lastPreReqTested[PrerequisiteConstants.KEY_CONTEXT_PATH];
                        key += "_" + lastContext;
                     }
                     if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_VALUE))
                     {
                        lastValue = lastPreReqTested[PrerequisiteConstants.KEY_VALUE];
                        key += "_" + lastValue;
                     }
                     if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_QUANTITY))
                     {
                        lastQuantity = lastPreReqTested[PrerequisiteConstants.KEY_QUANTITY];
                     }
                     message = "key not found: " + key;
                     if(ZLocUtils.hasString("Dialogs",key))
                     {
                        message = ZLocUtils.t("Dialogs",key,{
                           "type":lastType,
                           "value":lastValue,
                           "context":lastContext,
                           "quantity":lastQuantity
                        });
                     }
                  }
            }
         }
         return message;
      }
      
      private function onBuyClick(event:Event) : void
      {
         this.m_buyBt.visible = false;
         this.m_previewButton.visible = false;
         TransactionManager.addTransaction(new TGenericTransaction(UGCConstants.SERVICE_CLASS,UGCConstants.SERVICE_METHOD_UNLOCK_PART,null,[this.item.name]),true);
         FeatureOptionsManager.getInstance().setFeatureOption(UGCConstants.FO_AOE_LICENSE,this.item.aoeLicenseKey,true) as Boolean;
         Global.player.cash -= UGCConstants.DREAM_FISH_PART_UNLOCK_PRICE;
         StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_unlock","",this.item.name,"unlock","",UGCConstants.DREAM_FISH_PART_UNLOCK_PRICE.toString());
      }
      
      private function onPreviewClick(event:Event) : void
      {
      }
      
      public function showPreview() : Boolean
      {
         var result:Boolean = false;
         if(this.m_buyBt != null)
         {
            result = this.m_buyBt.visible;
         }
         return result;
      }
   }
}

