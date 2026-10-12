package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.GiftBoxConfirmationDialogSlot;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GiftBoxConfirmationDialog extends FarmWindow
   {
      
      private static const VALUE_FIELD:String = "valueField";
      
      private static const REWARD_FRAME:String = "rewardFrame";
      
      private static const ICON_FIELD:String = "iconField";
      
      private static const CURRENCY_COMMON_ASSET_PATH:String = "assets/consumables/";
      
      private static const DIALOG_WIDTH:int = 527;
      
      private static const OFFSET:int = 68.625;
      
      private static const IN_BETWEEN_DIS:int = 6;
      
      private static const X_START_POSITION:int = 0;
      
      private static const START_INDEX:String = "start";
      
      private static const END_INDEX:String = "end";
      
      protected var m_closeCallback:Function = null;
      
      private var m_data:Object;
      
      private var m_sellCallBack:Function;
      
      private var m_closeCallBack:Function;
      
      private var m_sellString:String = ZLocUtils.t("Dialogs","MarketPromo_ActionButton_FleaMarket");
      
      private var m_sellButton:FarmAnimatedTextButton;
      
      private var m_itemSlots:Object = {};
      
      private var m_assetPath:String;
      
      private var m_totalCoinsYield:int = 0;
      
      private var m_coinsAnimation:ZwWidget;
      
      private var m_coinsTextBox:FarmTextField;
      
      private var m_sellItems:Object = {};
      
      private var m_rewardData:Object = {};
      
      private var m_titleText:FarmTextField;
      
      private var m_currencyUIElementWidth:int;
      
      private var m_dialogWidth:int;
      
      public function GiftBoxConfirmationDialog(data:Object, assetPath:String, dialogWidth:int, sellCallBack:Function, closeCallBack:Function)
      {
         this.m_assetPath = assetPath;
         super(this.m_assetPath);
         this.m_data = data;
         this.m_sellCallBack = sellCallBack;
         this.m_closeCallBack = closeCallBack;
         this.m_dialogWidth = dialogWidth;
      }
      
      private function loadDisplay() : void
      {
         this.m_sellButton = addWidget(new FarmAnimatedTextButton(m_window["sellItemsPage_btn"],this.m_sellString,this.onSellSelected)) as FarmAnimatedTextButton;
         this.m_titleText = addWidget(new FarmTextField(m_window["sellselectedTitle_txt"],"Sell Selection ?")) as FarmTextField;
         var i:int = 0;
         while(m_window.hasOwnProperty("slot_" + i + "_mc") && this.m_data.hasOwnProperty(String(i)))
         {
            this.m_itemSlots[i] = addWidget(new GiftBoxConfirmationDialogSlot(m_window["slot_" + i + "_mc"],this.m_data[i],this.updateRewardData(i))) as GiftBoxConfirmationDialogSlot;
            i++;
         }
      }
      
      private function updateRewardData(index:int) : Function
      {
         var f:Function = function(changeInQuantity:int):void
         {
            var changeInReward:Object = null;
            changeInReward = calculateRewardDataForIndex(index,changeInQuantity);
            m_rewardData = mergeRewardData(changeInReward,m_rewardData);
            updateRewardUI();
         };
         return f;
      }
      
      private function mergeRewardData(changeInReward:Object, totalRewardData:Object) : Object
      {
         var index:String = null;
         for(index in changeInReward)
         {
            if(totalRewardData.hasOwnProperty(index))
            {
               totalRewardData[index] += changeInReward[index];
            }
            else
            {
               totalRewardData[index] = changeInReward[index];
            }
         }
         return totalRewardData;
      }
      
      private function updateRewardUI() : void
      {
         var currency:String = null;
         var cnt:int = 0;
         for(currency in this.m_rewardData)
         {
            if(!this.m_sellItems.hasOwnProperty(currency))
            {
               if(m_window.hasOwnProperty("sellItems" + cnt + "_mc"))
               {
                  this.m_sellItems[currency] = {};
                  this.m_sellItems[currency][REWARD_FRAME] = addWidget(new ZwFrame(m_window["sellItems" + cnt + "_mc"])) as ZwFrame;
                  this.m_sellItems[currency][VALUE_FIELD] = new FarmTextField(m_window["sellItems" + cnt + "_mc"]["coins_txt"],this.m_rewardData[currency]);
                  this.m_sellItems[currency][REWARD_FRAME].addWidget(this.m_sellItems[currency][VALUE_FIELD]);
                  this.m_sellItems[currency][ICON_FIELD] = new FarmIcon(m_window["sellItems" + cnt + "_mc"]["sellIcon_mc"],CURRENCY_COMMON_ASSET_PATH + currency + ".png");
                  this.m_sellItems[currency][ICON_FIELD].setIconSize(20,20);
                  this.m_sellItems[currency][REWARD_FRAME].addWidget(this.m_sellItems[currency][ICON_FIELD]);
               }
            }
            else
            {
               this.m_sellItems[currency][VALUE_FIELD].text = this.m_rewardData[currency];
            }
            cnt++;
         }
         this.placeRewards(cnt);
      }
      
      private function placeRewards(count:int) : void
      {
         var currency:String = null;
         var positions:Object = this.getPosition(X_START_POSITION,X_START_POSITION + this.m_dialogWidth,count,this.m_currencyUIElementWidth);
         var cnt:int = int(positions.start);
         for(currency in this.m_sellItems)
         {
            this.m_sellItems[currency][REWARD_FRAME].x = positions[cnt];
            cnt++;
         }
      }
      
      private function getPosition(startX:int, endX:int, noOfDiv:int, width:int) : Object
      {
         var i:int = 0;
         var result:Object = {};
         var centerPos:int = this.m_dialogWidth / 2 + OFFSET;
         var disFromCentre:int = 0;
         if(noOfDiv % 2 != 0)
         {
            result[0] = centerPos;
            result["start"] = 0;
            for(i = 1; i <= (noOfDiv - 1) / 2; i++)
            {
               disFromCentre = i * IN_BETWEEN_DIS + width;
               result[-i] = centerPos - disFromCentre;
               result[i] = centerPos + disFromCentre;
               result["start"] = -i;
            }
         }
         else
         {
            for(i = 1; i <= noOfDiv / 2; i++)
            {
               result["start"] = -i;
               if(i == 1)
               {
                  disFromCentre = i * IN_BETWEEN_DIS / 2 - width / 2;
                  result[-i] = centerPos - disFromCentre;
                  result[i] = centerPos + disFromCentre;
               }
               else
               {
                  disFromCentre = disFromCentre + IN_BETWEEN_DIS + width;
                  result[-i] = centerPos - disFromCentre;
                  result[i] = centerPos + disFromCentre;
               }
            }
         }
         return result;
      }
      
      private function calculateRewardDataForIndex(i:int, quantity:int) : Object
      {
         var coinYield:int = 0;
         var result:Object = {};
         if(this.m_data.hasOwnProperty(String(i)))
         {
            if(Boolean(this.m_data[i].hasOwnProperty("farmItem")) && Boolean(this.m_data[i].farmItem) && Boolean(this.m_data[i].farmItem["sellCurrency"]))
            {
               result[this.m_data[i].farmItem.sellCurrency] = quantity * this.m_data[i].farmItem.sellDisplayPrice;
               if(this.m_data[i].farmItem.sellCurrency != Currency.COINS)
               {
                  result[Currency.COINS] = quantity * this.m_data[i].farmItem.untunedSellPrice;
               }
            }
         }
         return result;
      }
      
      private function onSellSelected(ev:MouseEvent) : void
      {
         var data:Object = {};
         var count:int = 0;
         var i:int = 0;
         while(m_window.hasOwnProperty("slot_" + i + "_mc") && this.m_data.hasOwnProperty(String(i)))
         {
            data[count] = {
               "item":this.m_data[String(i)].farmItem,
               "quantitySelected":this.m_itemSlots[i].getQuantitySelected()
            };
            count++;
            i++;
         }
         data.length = count;
         this.m_sellCallBack(data);
         super.onClose(ev);
      }
      
      override protected function release() : void
      {
         this.m_data = null;
         this.m_sellCallBack = null;
         this.m_closeCallBack = null;
         this.m_sellString = null;
         this.m_sellButton = null;
         this.m_coinsTextBox = null;
         this.m_itemSlots = null;
         this.m_assetPath = null;
         this.m_coinsAnimation = null;
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_closeCallBack != null)
         {
            this.m_closeCallBack();
         }
         super.onClose(event);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.loadDisplay();
         if(m_window.hasOwnProperty("sellItems" + "0" + "_mc"))
         {
            this.m_currencyUIElementWidth = m_window["sellItems" + "0" + "_mc"].width;
         }
      }
   }
}

