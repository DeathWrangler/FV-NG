package Widgets.Slots.Storage
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TSellStoredItem;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.Market.MarketTooltip;
   import Widgets.Windows.SellAllAmountSelectionWindow;
   import Widgets.Windows.Storage.StorageWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class StorageSlot extends BaseStorageSlot
   {
      
      private static var defaultTitleHeight:uint;
      
      private static const DEFAULT_INFO_TEXT_COLOR:uint = 5543823;
      
      private static const ERROR_INFO_TEXT_COLOR:uint = 16711680;
      
      private static const MAX_SLOT_TITLE_TEXT_LEN:uint = 18;
      
      private var m_multilinepixelOffset:uint;
      
      private var m_desc_tf:ZwTextField;
      
      private var m_extra_tf:ZwTextField;
      
      private var m_help_bt:FarmAnimatedButton;
      
      private var m_sell_bt:FarmAnimatedTextButton;
      
      private var m_use_bt:FarmAnimatedTextButton;
      
      private var m_useString:String;
      
      private var m_lockedString:String;
      
      public function StorageSlot(element:DisplayObject, storageWindow:StorageWindow)
      {
         super(element,storageWindow);
         m_title_tf = addWidget(new ZwTextField(m_element.title_tf,"",true)) as ZwTextField;
         m_itemCount_tf = addWidget(new ZwTextField(m_element.itemCount_tf)) as ZwTextField;
         m_icon_mc = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         m_icon_mc.setIconSize(50,50);
         this.m_desc_tf = addWidget(new ZwTextField(m_element.desc_tf)) as ZwTextField;
         this.m_extra_tf = addWidget(new ZwTextField(m_element.extra_tf,ZLocUtils.t("Dialogs","storage_locked"))) as ZwTextField;
         this.m_extra_tf.color = ERROR_INFO_TEXT_COLOR;
         this.m_help_bt = addWidget(new FarmAnimatedButton(m_element.question_bt)) as FarmAnimatedButton;
         this.m_help_bt.attachTooltip(new MarketTooltip());
         this.m_sell_bt = addWidget(new FarmAnimatedTextButton(m_element.sell_bt,ZLocUtils.t("Dialogs","Sell"),this.onSellClick)) as FarmAnimatedTextButton;
         this.m_useString = ZLocUtils.t("Dialogs","Use");
         this.m_lockedString = ZLocUtils.t("Dialogs","storage_locked");
         this.m_use_bt = addWidget(new FarmAnimatedTextButton(m_element.use_bt,this.m_useString,onUseClick)) as FarmAnimatedTextButton;
         if(m_title_tf.hasOwnProperty("height"))
         {
            if(m_title_tf.height > 0)
            {
               defaultTitleHeight = m_title_tf.height;
               this.m_multilinepixelOffset = uint(m_title_tf.getTextFormat().size);
               if(this.m_multilinepixelOffset == 0)
               {
                  this.m_multilinepixelOffset = 15;
               }
            }
            else
            {
               defaultTitleHeight = 15;
            }
         }
      }
      
      override public function release() : void
      {
         super.release();
         m_storageWindow = null;
         m_data = null;
         m_farmItem = null;
         m_title_tf = null;
         m_itemCount_tf = null;
         this.m_desc_tf = null;
         this.m_extra_tf = null;
         m_icon_mc = null;
         this.m_help_bt = null;
         this.m_sell_bt = null;
         this.m_use_bt = null;
      }
      
      override public function populate(data:Object) : void
      {
         var word_array:Array = null;
         var formattedStr:String = null;
         var i:uint = 0;
         m_data = data;
         m_farmItem = Global.farmGameSettingsManager.getFarmItemByName(data.itemName);
         var multilineName:Boolean = false;
         var lineCount:uint = 0;
         if(m_farmItem.friendlyTitle.length > MAX_SLOT_TITLE_TEXT_LEN)
         {
            m_title_tf.wordWrap = true;
            m_title_tf.setMultiline(true);
            word_array = m_farmItem.friendlyTitle.split(" ");
            formattedStr = "";
            for(i = 0; i < word_array.length; i++)
            {
               if(formattedStr.length + word_array[i].toString().length < MAX_SLOT_TITLE_TEXT_LEN)
               {
                  formattedStr += word_array[i] + " ";
               }
               else
               {
                  formattedStr += "\n" + word_array[i] + " ";
                  lineCount += 1;
                  multilineName = true;
               }
            }
            m_title_tf.text = formattedStr;
            m_title_tf.height = defaultTitleHeight + lineCount * this.m_multilinepixelOffset;
         }
         else
         {
            m_title_tf.text = m_farmItem.friendlyTitle;
         }
         if(m_title_tf.text == "" && m_farmItem.className != null && m_farmItem.className != "")
         {
            m_title_tf.text = ZLocUtils.tk_pk_asTitle("Items:" + m_farmItem.className + "_friendlyName");
         }
         m_title_tf.visible = true;
         m_icon_mc.loadIcon(m_farmItem.icon);
         m_icon_mc.visible = true;
         m_itemCount_tf.text = "x" + m_storageWindow.usedTypes[m_data.code];
         m_itemCount_tf.visible = true;
         if(m_farmItem.sellPrice > 0)
         {
            this.m_desc_tf.enabled = false;
            this.m_desc_tf.text = ZLocUtils.t("Dialogs","storage_sell_price",{
               "quantity":m_farmItem.sellDisplayPrice,
               "coinword":ZLocUtils.tk("FarmGame",m_farmItem.sellCurrency,"",m_farmItem.sellDisplayPrice)
            });
            this.m_desc_tf.visible = true;
            this.m_sell_bt.visible = true;
            this.m_desc_tf.y = defaultTitleHeight + lineCount * this.m_multilinepixelOffset;
         }
         this.m_use_bt.visible = true;
         var itemIsWorldLocked:Boolean = !m_farmItem.meetsRequirments;
         if(itemIsWorldLocked == false)
         {
            this.m_use_bt.enabled = true;
            this.m_use_bt.text = this.m_useString;
         }
         else
         {
            this.m_use_bt.enabled = false;
            this.m_use_bt.text = this.m_lockedString;
            this.m_extra_tf.visible = true;
         }
         var tooltipText:String = m_farmItem.getUsageDescription();
         if(m_farmItem.hasWhatIsThis && Boolean(tooltipText))
         {
            this.m_help_bt.visible = true;
            (this.m_help_bt.tooltip as MarketTooltip).setText(tooltipText);
         }
      }
      
      protected function onSellClick(event:MouseEvent) : void
      {
         m_storageWindow.setButtonEnable(false);
         var maxAmount:int = !m_data.allowMultiSell ? 1 : int(m_storageWindow.usedTypes[m_data.code]);
         UI.displayPopup(new SellAllAmountSelectionWindow(m_farmItem,maxAmount,1,this.sellMultipleGiftsHandler,this.closeMultipleSellHandler),false);
      }
      
      protected function closeMultipleSellHandler(e:Event) : void
      {
         m_storageWindow.setButtonEnable(true);
      }
      
      protected function sellMultipleGiftsHandler(data:Object) : void
      {
         var item:FarmItem = null;
         var quantity:int = 0;
         if(data != null && data.item != null && data.quantitySelected != null)
         {
            item = data.item;
            quantity = int(data.quantitySelected);
            FarmStatsManager.sample(100,"Storage","goods","sold");
            TransactionManager.addTransaction(new TSellStoredItem(m_data.itemKey,false,this.onSellComplete,Global.player.currentStorageWorldId,quantity),true);
         }
      }
      
      protected function onSellComplete(result:Object) : void
      {
         m_storageWindow.setButtonEnable(true);
         Global.player.removeInventoryItem(m_data.itemKey,result.qtySold,Global.player.currentStorageWorldId);
         FarmStatsManager.sample(100,"Storage","goods","sold");
         m_storageWindow.reload();
      }
      
      public function setButtonEnable(enable:Boolean) : void
      {
         if(m_farmItem)
         {
            this.m_help_bt.enabled = enable;
            this.m_sell_bt.enabled = enable;
            this.m_use_bt.enabled = enable && m_storageWindow.isUseable() && m_farmItem.meetsRequirments;
         }
      }
   }
}

