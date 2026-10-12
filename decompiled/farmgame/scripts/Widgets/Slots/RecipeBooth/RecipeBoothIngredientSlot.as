package Widgets.Slots.RecipeBooth
{
   import Classes.FeatureBuilding;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.RecipeBoothManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.RecipeBooth.RecipeBoothWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public final class RecipeBoothIngredientSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private static const MAX_COUNT:int = 99;
      
      private var m_parentWindow:RecipeBoothWindow;
      
      private var m_itemName:String;
      
      private var m_minimum:int;
      
      private var m_owned:int;
      
      private var m_count:int;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_countTextField:ZwTextField;
      
      private var m_ownedTextField:ZwTextField;
      
      private var m_incrementButton:FarmAnimatedButton;
      
      private var m_decrementButton:FarmAnimatedButton;
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_askFeedPending:Boolean = false;
      
      private var m_askTimer:Timer;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      public function RecipeBoothIngredientSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.card_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.cardname_tf," ")) as ZwTextField;
         this.m_countTextField = addWidget(new ZwTextField(m_element.count_tf," ")) as ZwTextField;
         this.m_ownedTextField = addWidget(new ZwTextField(m_element.inventory_tf," ")) as ZwTextField;
         this.m_incrementButton = addWidget(new FarmAnimatedButton(m_element.rightArrow_bt,this.onIncrementButtonClick)) as FarmAnimatedButton;
         this.m_decrementButton = addWidget(new FarmAnimatedButton(m_element.leftArrow_bt,this.onDecrementButtonClick)) as FarmAnimatedButton;
         this.m_askButton = addWidget(new FarmAnimatedTextButton(m_element.ask_bt,"",this.onAskButtonClick)) as FarmAnimatedTextButton;
         this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,"Buy","00",this.onBuyButtonClick)) as FarmAnimatedCashButton;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         if(data)
         {
            this.m_itemName = data[RecipeBoothManager.KEY_ITEM_NAME] as String;
            this.m_minimum = data[RecipeBoothManager.KEY_MINIMUM] as int;
            this.m_count = this.m_minimum;
         }
         this.refresh();
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_nameTextField = null;
         this.m_countTextField = null;
         this.m_ownedTextField = null;
         this.m_incrementButton = null;
         this.m_decrementButton = null;
         this.m_askButton = null;
         this.m_buyButton = null;
         if(this.m_askTimer)
         {
            this.m_askTimer.removeEventListener(TimerEvent.TIMER,this.onAskButtonTimer);
            this.m_askTimer.stop();
            this.m_askTimer = null;
         }
         super.release();
      }
      
      public function get parentWindow() : RecipeBoothWindow
      {
         if(!this.m_parentWindow)
         {
            this.m_parentWindow = getAncestorByClassType(RecipeBoothWindow) as RecipeBoothWindow;
         }
         return this.m_parentWindow;
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      public function get count() : int
      {
         return this.m_count;
      }
      
      public function get hasEnough() : Boolean
      {
         return this.m_count >= this.m_minimum;
      }
      
      private function getRequestType() : String
      {
         var requestTypes:Array = null;
         var requestType:Object = null;
         var prereqName:String = null;
         var result:String = FeatureBuilding.DEFAULT_PART_ASK_METHOD;
         if(Boolean(this.parentWindow) && Boolean(this.parentWindow.building))
         {
            requestTypes = this.parentWindow.building.getRequestTypes(this.m_itemName);
            if(requestTypes)
            {
               for each(requestType in requestTypes)
               {
                  prereqName = requestType["prereq"];
                  if(!prereqName || PrerequisiteUtility.checkPrereqByName(prereqName))
                  {
                     result = requestType["type"];
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function deductCount() : void
      {
         Global.player.removeGiftWithKey(Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_itemName),this.m_count);
         this.refresh();
      }
      
      public function refresh() : void
      {
         var item:FarmItem = null;
         var nameTextKey:String = null;
         var nameText:String = null;
         var netCount:int = 0;
         var countPlusOne:int = 0;
         if(this.m_itemName)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
            if(item)
            {
               this.m_icon.loadIcon(item.iconUrl);
               this.m_icon.visible = true;
               nameTextKey = this.parentWindow.featureName + "_" + this.m_itemName + "_ShortName";
               nameText = ZLocUtils.hasString("Dialogs",nameTextKey) ? ZLocUtils.t("Dialogs",nameTextKey) : item.friendlyTitle;
               this.m_nameTextField.text = nameText;
               this.m_nameTextField.visible = true;
               this.m_owned = Global.player.getGiftCountForItem(this.m_itemName);
               netCount = Math.max(this.m_owned - this.m_count,0);
               this.m_ownedTextField.text = "x" + String(netCount);
               this.m_ownedTextField.visible = true;
               if(this.m_count > this.m_owned)
               {
                  this.m_count = this.m_owned;
               }
               this.m_countTextField.text = String(this.m_count);
               this.m_countTextField.visible = true;
               countPlusOne = this.m_count + 1;
               this.m_incrementButton.enabled = countPlusOne <= this.m_owned && countPlusOne <= MAX_COUNT;
               this.m_incrementButton.visible = true;
               this.m_decrementButton.enabled = this.m_count - 1 >= this.m_minimum;
               this.m_decrementButton.visible = true;
               this.refreshAskButton();
               if(item.buyable && item.buyableWithCash())
               {
                  this.m_buyButton.setAmountText(String(item.cash));
                  this.m_buyButton.visible = true;
               }
            }
         }
      }
      
      public function refreshAskButton() : void
      {
         var item:FarmItem = null;
         var requestType:String = null;
         var askButtonKey:String = null;
         var askButtonText:String = null;
         var canRequestPart:Boolean = false;
         var timeUntilPost:int = 0;
         var timeUntilPostText:String = null;
         if(Boolean(this.m_askButton) && Boolean(this.parentWindow) && Boolean(this.parentWindow.building))
         {
            this.m_askButton.visible = true;
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
            if(item)
            {
               requestType = this.getRequestType();
               if(requestType)
               {
                  askButtonKey = this.parentWindow.featureName + "_AskButton";
                  askButtonText = ZLocUtils.hasString("Dialogs",askButtonKey) ? ZLocUtils.t("Dialogs",askButtonKey) : ZLocUtils.t("Dialogs","Ask");
                  if(requestType == FeatureBuilding.PART_ASK_METHOD_FEED)
                  {
                     canRequestPart = this.parentWindow.building.canRequestPartFeed(item.code);
                     this.m_askButton.enabled = !this.m_askFeedPending && canRequestPart;
                     if(this.m_askButton.enabled)
                     {
                        this.m_askButton.text = askButtonText;
                        if(this.m_askTimer)
                        {
                           this.m_askTimer.stop();
                           this.m_askTimer.removeEventListener(TimerEvent.TIMER,this.onAskButtonTimer);
                           this.m_askTimer = null;
                        }
                     }
                     else
                     {
                        timeUntilPost = this.parentWindow.building.getTimeUntilPostAnotherFeed(item.code);
                        timeUntilPostText = FarmGameUtil.toFriendlyTime(timeUntilPost,true);
                        this.m_askButton.text = ZLocUtils.t("Dialogs","RecipeBooth_AskIn",{"time":timeUntilPostText});
                        if(!this.m_askTimer)
                        {
                           this.m_askTimer = new Timer(1000);
                           this.m_askTimer.addEventListener(TimerEvent.TIMER,this.onAskButtonTimer);
                           this.m_askTimer.start();
                        }
                     }
                  }
                  else
                  {
                     this.m_askButton.text = askButtonText;
                     this.m_askButton.enabled = true;
                  }
               }
               else
               {
                  this.m_askButton.visible = false;
               }
            }
         }
      }
      
      private function onAskButtonTimer(event:TimerEvent) : void
      {
         this.refreshAskButton();
      }
      
      private function refreshSubmitButton() : void
      {
         this.parentWindow.refreshSubmitButton();
      }
      
      private function onIncrementButtonClick(event:MouseEvent) : void
      {
         if(this.m_incrementButton.enabled)
         {
            if(this.m_count + 1 <= this.m_owned)
            {
               ++this.m_count;
               this.m_countTextField.text = String(this.m_count);
               this.refresh();
               this.refreshSubmitButton();
            }
         }
      }
      
      private function onDecrementButtonClick(event:MouseEvent) : void
      {
         if(this.m_decrementButton.enabled)
         {
            if(this.m_count - 1 >= this.m_minimum)
            {
               --this.m_count;
               this.m_countTextField.text = String(this.m_count);
               this.refresh();
               this.refreshSubmitButton();
            }
         }
      }
      
      private function onAskButtonClick(event:MouseEvent) : void
      {
         var item:FarmItem = null;
         var requestType:String = null;
         if(this.m_askButton.enabled)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
            if(item)
            {
               requestType = this.getRequestType();
               if(requestType)
               {
                  if(requestType == FeatureBuilding.PART_ASK_METHOD_FEED)
                  {
                     RecipeBoothManager.requestIngredient(this.parentWindow.building,item,this.askFeedCallback,FeatureBuilding.PART_ASK_METHOD_FEED,this.parentWindow.featureName + "_AskPart");
                     this.m_askFeedPending = true;
                     this.m_askButton.enabled = false;
                  }
                  else
                  {
                     RecipeBoothManager.requestIngredient(this.parentWindow.building,item,null,requestType);
                  }
               }
            }
         }
      }
      
      private function askFeedCallback(result:Object = null) : void
      {
         this.m_askFeedPending = false;
         this.parentWindow.refreshAskButtons();
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var item:FarmItem = null;
         if(this.m_buyButton.enabled)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
            if(item)
            {
               Global.player.buyFarmItem(item,Currency.CASH,1,true,false,true,null,true);
               if(this.m_count + 1 <= MAX_COUNT)
               {
                  ++this.m_count;
               }
               this.refresh();
               this.refreshSubmitButton();
               FarmStatsManager.count(this.parentWindow.featureName,"buy_ingredient",this.m_itemName);
            }
         }
      }
   }
}

