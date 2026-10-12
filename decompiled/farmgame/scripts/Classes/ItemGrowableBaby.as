package Classes
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmGameSettingsManager;
   import flash.events.MouseEvent;
   
   public class ItemGrowableBaby extends GrowableBaby
   {
      
      private const ANIMAL_CRAFT_FEED:String = "animal_craft_feed";
      
      private const ANIMAL_BUY_FEED:String = "animal_buy_feed";
      
      protected var m_growItemNeeded:String;
      
      protected var m_growItemFriendly:String;
      
      protected var m_recipeId:String;
      
      public function ItemGrowableBaby(animalType:String = null)
      {
         var xml:XML = null;
         super(animalType);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_growItemNeeded = getItem().getStringFromDataSource("feedItem");
         }
         else
         {
            xml = this.getItem().xml;
            this.m_growItemNeeded = xml.feedItem;
         }
         var growItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_growItemNeeded);
         this.m_growItemFriendly = growItem.friendlyTitle;
         var recipe:RecipeItem = Global.craftConfigSettings.getRecipeByProductItemCode(growItem.code);
         if(recipe != null)
         {
            this.m_recipeId = recipe.id;
         }
      }
      
      override protected function generateMenuItems() : void
      {
         super.generateMenuItems();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_DREAM_DEER_FEED) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START && Boolean(this.m_growItemNeeded))
         {
            if(this.m_recipeId)
            {
               m_menuItems.unshift({
                  "label":ZLocUtils.t("Dialogs","AnimalBreedingGeneric_CraftFeedContextMenu",{"itemName":this.m_growItemFriendly}),
                  "action":this.ANIMAL_CRAFT_FEED
               });
            }
            m_menuItems.unshift({
               "label":ZLocUtils.t("Dialogs","AnimalBreedingGeneric_BuyFeedContextMenu",{"itemName":this.m_growItemFriendly}),
               "action":this.ANIMAL_BUY_FEED
            });
         }
      }
      
      override public function shouldConfirmGrowUp() : Boolean
      {
         return false;
      }
      
      override public function paymentName() : String
      {
         return this.m_growItemFriendly;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var craftShop:String = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(m_wanderingObject != this)
            {
               generateWanderTime();
               switch(item.action)
               {
                  case this.ANIMAL_CRAFT_FEED:
                     craftShop = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
                     CraftingManager.getInstance().openCraftingUiForRecipe(this.m_recipeId,craftShop);
                     break;
                  case this.ANIMAL_BUY_FEED:
                     this.showMarketWithItem();
                     break;
                  default:
                     super.onMenuClick(event);
               }
            }
         }
      }
      
      private function showMarketWithItem() : void
      {
         if(UI.windowState == null)
         {
            UI.windowState = {"market":{}};
         }
         else if(UI.windowState.market == null)
         {
            UI.windowState.market = {};
         }
         UI.windowState.market["searchString"] = this.m_growItemFriendly;
         UI.displayMarketDialog("unknown","seed",null,"all",this.resetMarketSearch);
      }
      
      private function resetMarketSearch(isBuy:Boolean) : void
      {
         UI.windowState.market = {};
      }
      
      override protected function transformFailed() : void
      {
         UI.displayMessage(ZLocUtils.t_pk("Dialogs","NotEnoughItemToTransform",{
            "itemName":this.m_growItemFriendly,
            "itemHave":Global.player.getGiftCountForItem(this.m_growItemNeeded),
            "itemNeed":m_growPrice
         }),GenericPopup.TYPE_YESNO,this.failTransformDialogCallback);
      }
      
      protected function failTransformDialogCallback(data:Object = null) : void
      {
         if(data.button == GenericPopup.YES)
         {
            this.showMarketWithItem();
         }
      }
      
      override protected function canTransform() : Boolean
      {
         var giftNum:int = Global.player.getGiftCountForItem(this.m_growItemNeeded);
         return giftNum >= m_growPrice;
      }
      
      override protected function chargeTransform() : Boolean
      {
         var result:Boolean = false;
         var giftCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_growItemNeeded);
         var giftNum:int = Global.player.getGiftCountForItemKey(giftCode);
         if(giftNum >= m_growPrice)
         {
            Global.player.removeGiftWithKey(giftCode,m_growPrice);
            result = true;
         }
         return result;
      }
   }
}

