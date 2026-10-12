package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Managers.FarmStatsManager;
   import Managers.TurtleInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.TurtleInnovationGiftFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class TurtleInnovationGiftSlot extends ZwSlotFrame
   {
      
      private static var m_rewardsNameArray:Array = ["reward_0_mc","reward_1_mc","reward_2_mc","reward_3_mc","reward_4_mc"];
      
      private static const ICON_WIDTH:int = 50;
      
      private static const ICON_HEIGHT:int = 50;
      
      private const TRADE_BT:String = "trade_bt";
      
      private var m_featureName:String;
      
      private var m_collection:Object;
      
      private var m_elementFrame:ZwFrame;
      
      private var m_elements1_mcFrame:ZwFrame;
      
      private var m_elements2_mcFrame:ZwFrame;
      
      private var m_elements4_mcFrame:ZwFrame;
      
      private var m_numberofCons:Number = 0;
      
      private var m_redeemButton:FarmAnimatedTextButton;
      
      private var m_buyBonusBtn:FarmAnimatedCashButton;
      
      private var m_bonusAward:ZwFrame;
      
      protected var m_iconPreview:FarmAnimatedButton;
      
      private var m_windowPageFrame:TurtleInnovationGiftFrame;
      
      private var m_bonusCheckmarkIcon:ZwWidget;
      
      private var m_BonusIconPreview:FarmIcon;
      
      private var m_bonusItem:FarmItem;
      
      private var m_collectionNameTf:FarmTextField;
      
      private var m_TurtleRewardsDetailSlot:TurtleRewardsDetailSlot;
      
      private var m_redeemToolTip:FarmTextTooltip;
      
      private var m_SlotArray:Array;
      
      private var m_elementIconArray1:Array;
      
      private var m_elementIconArray2:Array;
      
      private var m_elementIconArray4:Array;
      
      private var m_elementCounterArray1:Array;
      
      private var m_elementCounterArray2:Array;
      
      private var m_elementCounterArray4:Array;
      
      public function TurtleInnovationGiftSlot(element:DisplayObject, featureName:String, windowPageFrame:TurtleInnovationGiftFrame)
      {
         var i:int = 0;
         var elementName:String = null;
         super(element);
         this.m_featureName = featureName;
         this.m_SlotArray = new Array();
         this.m_windowPageFrame = windowPageFrame;
         if(m_element.hasOwnProperty(this.TRADE_BT))
         {
            addWidget(this.m_redeemButton = new FarmAnimatedTextButton(m_element[this.TRADE_BT],"Redeem",this.onRedeemItem),true);
         }
         var icon:FarmIcon = null;
         var counterTf:FarmTextField = null;
         if(m_element.hasOwnProperty("elements1_mc"))
         {
            addWidget(this.m_elements1_mcFrame = new ZwFrame(m_element.elements1_mc));
            if(m_element.elements1_mc.hasOwnProperty("element"))
            {
               this.m_elementIconArray1 = new Array();
               this.m_elementCounterArray1 = new Array();
               this.m_elements1_mcFrame.addWidget(this.m_elementFrame = new ZwFrame(m_element.elements1_mc.element));
               this.m_elementFrame.addWidget(icon = new FarmIcon(m_element.elements1_mc.element.icon_mc));
               this.m_elementIconArray1.push(icon);
               this.m_elementFrame.addWidget(counterTf = new FarmTextField(m_element.elements1_mc.element.count_tf,""));
               this.m_elementCounterArray1.push(counterTf);
            }
         }
         if(m_element.hasOwnProperty("elements2_mc"))
         {
            addWidget(this.m_elements2_mcFrame = new ZwFrame(m_element.elements2_mc));
            this.m_elementIconArray2 = new Array();
            this.m_elementCounterArray2 = new Array();
            for(i = 1; i <= 2; i++)
            {
               elementName = "element" + i;
               this.m_elements2_mcFrame.addWidget(this.m_elementFrame = new ZwFrame(m_element["elements2_mc"][elementName]));
               this.m_elementFrame.addWidget(icon = new FarmIcon(m_element.elements2_mc[elementName]["icon_mc"]));
               this.m_elementIconArray2.push(icon);
               this.m_elementFrame.addWidget(counterTf = new FarmTextField(m_element.elements2_mc[elementName]["count_tf"],""));
               this.m_elementCounterArray2.push(counterTf);
            }
         }
         if(m_element.hasOwnProperty("elements4_mc"))
         {
            this.m_elementIconArray4 = new Array();
            this.m_elementCounterArray4 = new Array();
            addWidget(this.m_elements4_mcFrame = new ZwFrame(m_element.elements4_mc));
            for(i = 1; i <= 4; i++)
            {
               elementName = "element" + i;
               this.m_elements4_mcFrame.addWidget(this.m_elementFrame = new ZwFrame(m_element["elements4_mc"][elementName]));
               this.m_elementFrame.addWidget(icon = new FarmIcon(m_element.elements4_mc[elementName]["icon_mc"]));
               this.m_elementIconArray4.push(icon);
               this.m_elementFrame.addWidget(counterTf = new FarmTextField(m_element.elements4_mc[elementName]["count_tf"],""));
               this.m_elementCounterArray4.push(counterTf);
            }
         }
         for(i = 0; i < TurtleInnovationGiftSlot.m_rewardsNameArray.length; i++)
         {
            addWidget(this.m_TurtleRewardsDetailSlot = new TurtleRewardsDetailSlot(m_element[m_rewardsNameArray[i]]));
            this.m_SlotArray.push(this.m_TurtleRewardsDetailSlot);
         }
         if(m_element.hasOwnProperty("bonus_mc"))
         {
            addWidget(this.m_bonusAward = new ZwFrame(m_element["bonus_mc"]),false);
            if(Boolean(m_element.bonus_mc.hasOwnProperty("icon_mc")) && Boolean(m_element.bonus_mc.hasOwnProperty("checkmark_mc")) && Boolean(m_element.bonus_mc.hasOwnProperty("bt_buy")))
            {
               this.m_bonusAward.addWidget(this.m_buyBonusBtn = new FarmAnimatedCashButton(m_element.bonus_mc.bt_buy,"Buy","",this.onBuyBonusClick),false);
               this.m_bonusAward.addWidget(this.m_BonusIconPreview = new FarmIcon(m_element.bonus_mc.icon_mc),false);
               this.m_bonusAward.addWidget(this.m_bonusCheckmarkIcon = new ZwWidget(m_element.bonus_mc.checkmark_mc),false);
            }
            if(m_element.bonus_mc.hasOwnProperty("preview_mc"))
            {
               addWidget(this.m_iconPreview = new FarmAnimatedButton(m_element.bonus_mc.preview_mc,this.onPreviewClick),false);
            }
         }
         if(m_element["name_tf"])
         {
            addWidget(this.m_collectionNameTf = new FarmTextField(m_element["name_tf"],""),false);
         }
      }
      
      private static function countKeys(myDictionary:Dictionary) : int
      {
         var key:* = undefined;
         var n:int = 0;
         if(myDictionary)
         {
            for(key in myDictionary)
            {
               n++;
            }
         }
         return n;
      }
      
      override public function populate(data:Object) : void
      {
         var rewardItem:FarmItem = null;
         var item:Object = null;
         var text:String = null;
         var consumableName:String = null;
         var consumableItem:FarmItem = null;
         var consumableFriendlyName:String = null;
         super.populate(data);
         this.m_collection = data;
         this.m_bonusItem = Global.farmGameSettingsManager.getFarmItemByName(data["collectionCompleteReward"]);
         if(Boolean(this.m_BonusIconPreview) && Boolean(this.m_bonusItem))
         {
            this.m_bonusAward.visible = true;
            this.m_BonusIconPreview.alpha = 0.5;
            this.m_BonusIconPreview.visible = true;
            this.m_BonusIconPreview.loadIcon(this.m_bonusItem.getImageByName("feed",false));
            this.m_BonusIconPreview.setIconHeight(120);
            this.m_BonusIconPreview.setIconWidth(120);
         }
         if(Boolean(this.m_iconPreview) && Boolean(this.m_bonusItem))
         {
            this.m_iconPreview.visible = true;
         }
         if(this.m_collectionNameTf)
         {
            this.m_collectionNameTf.text = TurtleInnovationManager.getFriendlyName(this.m_collection.name);
            this.m_collectionNameTf.visible = true;
         }
         if(this.m_redeemButton)
         {
            this.m_redeemButton.visible = true;
            if(TurtleInnovationManager.getInstance().isCollectionRedeemable(data))
            {
               this.m_redeemButton.enabled = true;
               this.m_redeemButton.detachTooltip();
               this.m_redeemButton.attachTooltip(new FarmTextTooltip("Redeem stones for an item from the collection at random"));
            }
            else
            {
               if(this.m_redeemButton.tooltip)
               {
                  this.m_redeemButton.detachTooltip();
               }
               FarmGameUtil.disableButtonAndShowTooltip(this.m_redeemButton,"Collect stones to start redeeming the collection");
            }
         }
         if(Boolean(this.m_buyBonusBtn && this.m_bonusCheckmarkIcon) && Boolean(this.m_bonusItem) && TurtleInnovationManager.getInstance().isCollectionRewardRedeemed(this.m_collection.name))
         {
            this.m_bonusCheckmarkIcon.visible = true;
            this.m_BonusIconPreview.alpha = 1;
            this.m_buyBonusBtn.visible = true;
            this.m_buyBonusBtn.setAmountText(this.m_bonusItem.cash.toString());
         }
         else
         {
            this.m_bonusCheckmarkIcon.visible = false;
            this.m_buyBonusBtn.visible = false;
         }
         var itemSwf:String = null;
         for(var i:int = 0; i < TurtleInnovationGiftSlot.m_rewardsNameArray.length; i++)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(data["items"][i]["name"]);
            itemSwf = this.m_collection.items[i].assetUrl ? this.m_collection.items[i].assetUrl : null;
            this.m_SlotArray[i].update(rewardItem,this.m_collection.name,itemSwf);
         }
         for each(item in this.m_SlotArray)
         {
            item.visible = true;
         }
         this.m_numberofCons = countKeys(data["consumables"]);
         switch(this.m_numberofCons)
         {
            case 1:
               this.m_elements1_mcFrame.visible = true;
               i = 0;
               for(consumableName in data["consumables"])
               {
                  consumableFriendlyName = TurtleInnovationManager.getFriendlyName(consumableName);
                  consumableItem = Global.farmGameSettingsManager.getFarmItemByName(consumableName);
                  this.m_elementIconArray1[i].loadIcon(consumableItem.icon);
                  this.m_elementIconArray1[i].setIconHeight(100);
                  this.m_elementIconArray1[i].setIconWidth(100);
                  text = TurtleInnovationManager.getInstance().getConsumableItemCountByName(consumableName).toString();
                  text = text + "/" + data["consumables"][consumableName];
                  this.m_elementCounterArray1[i].text = text;
                  if(this.m_elementIconArray1[i].tooltip)
                  {
                     this.m_elementIconArray1[i].detachTooltip();
                  }
                  this.m_elementIconArray1[i].attachTooltip(new FarmTextTooltip(consumableFriendlyName));
                  i++;
               }
               break;
            case 2:
               i = 0;
               this.m_elements2_mcFrame.visible = true;
               for(consumableName in data["consumables"])
               {
                  consumableFriendlyName = TurtleInnovationManager.getFriendlyName(consumableName);
                  consumableItem = Global.farmGameSettingsManager.getFarmItemByName(consumableName);
                  this.m_elementIconArray2[i].loadIcon(consumableItem.icon);
                  this.m_elementIconArray2[i].setIconHeight(70);
                  this.m_elementIconArray2[i].setIconWidth(70);
                  text = TurtleInnovationManager.getInstance().getConsumableItemCountByName(consumableName).toString();
                  text = text + "/" + data["consumables"][consumableName];
                  this.m_elementCounterArray2[i].text = text;
                  if(this.m_elementIconArray2[i].tooltip)
                  {
                     this.m_elementIconArray2[i].detachTooltip();
                  }
                  this.m_elementIconArray2[i].attachTooltip(new FarmTextTooltip(consumableFriendlyName));
                  i++;
               }
               break;
            case 4:
               i = 0;
               this.m_elements4_mcFrame.visible = true;
               for(consumableName in data["consumables"])
               {
                  consumableFriendlyName = TurtleInnovationManager.getFriendlyName(consumableName);
                  consumableItem = Global.farmGameSettingsManager.getFarmItemByName(consumableName);
                  this.m_elementIconArray4[i].loadIcon(consumableItem.icon);
                  this.m_elementIconArray4[i].setIconHeight(50);
                  this.m_elementIconArray4[i].setIconWidth(50);
                  text = TurtleInnovationManager.getInstance().getConsumableItemCountByName(consumableName).toString();
                  text = text + "/" + data["consumables"][consumableName];
                  this.m_elementCounterArray4[i].text = text;
                  if(this.m_elementIconArray4[i].tooltip)
                  {
                     this.m_elementIconArray4[i].detachTooltip();
                  }
                  this.m_elementIconArray4[i].attachTooltip(new FarmTextTooltip(consumableFriendlyName));
                  i++;
               }
         }
      }
      
      public function onBuyBonusClick(event:Event) : void
      {
         TurtleInnovationManager.getInstance().buyItem(this.m_bonusItem,this.m_collection.name);
      }
      
      public function onPreviewClick(event:MouseEvent) : void
      {
         TurtleInnovationManager.getInstance().showPreviewWindow(this.m_bonusItem);
         FarmStatsManager.count("tenguann_collections_ui","item_preview",this.m_collection.name,this.m_bonusItem.name);
      }
      
      private function onRedeemItem(event:Event) : void
      {
         if(this.m_redeemButton.enabled)
         {
            if(this.m_redeemButton.tooltip)
            {
               this.m_redeemButton.tooltip.release();
            }
            TurtleInnovationManager.getInstance(this.m_featureName).redeemCollection(this.m_collection);
            TurtleInnovationManager.getInstance().m_turtleCollectionWindow.refreshWindow();
         }
      }
   }
}

