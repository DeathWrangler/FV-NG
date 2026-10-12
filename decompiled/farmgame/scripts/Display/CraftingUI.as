package Display
{
   import Classes.CraftingCottageBuilding;
   import Classes.FeatureBuilding;
   import Classes.MarketStallBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Events.CloseEvent;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.Crafting.SmartBushelHelper;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.Crafting.CraftingGetGoodsWindow;
   import Widgets.Windows.Crafting.CraftingMainWindow;
   import Widgets.Windows.Crafting.CraftingMySalesWindow;
   import Widgets.Windows.Crafting.CraftingSiloWindow;
   import Widgets.Windows.Crafting.CraftingUseGoodsWindow;
   import Widgets.Windows.Crafting.HomeMarketStallWindow;
   import Widgets.Windows.Crafting.LimitedRecipeWindow;
   import Widgets.Windows.Crafting.SalesReportWindow;
   import Widgets.Windows.Crafting.ShoppingListWindow;
   import Widgets.Windows.Crafting.VisitingMarketStallWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.IconTitleToasterWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class CraftingUI extends UI
   {
      
      private static var m_homeMarketStallWindow:HomeMarketStallWindow = null;
      
      private static var m_craftingSiloWindow:CraftingSiloWindow = null;
      
      private static var m_visitingMarketStallWindow:VisitingMarketStallWindow = null;
      
      private static var m_visitingMarketStallWindowCloseCallback:Function = null;
      
      private static var m_salesReportWindow:SalesReportWindow = null;
      
      private static var m_craftingMySalesWindow:CraftingMySalesWindow = null;
      
      private static var m_craftingGetGoodsWindow:CraftingGetGoodsWindow = null;
      
      private static var m_craftingUseGoodsWindow:CraftingUseGoodsWindow = null;
      
      private static var m_shoppingListWindow:ShoppingListWindow = null;
      
      private static var m_closeShoppingListWindowCallback:Function = null;
      
      private static var m_closeMarketStallWindowCallback:Function = null;
      
      private static var m_closeCraftingSiloWindowCallback:Function = null;
      
      private static var m_closeSalesReportWindowCallback:Function = null;
      
      private static var m_closeCraftingMySalesWindowCallback:Function = null;
      
      private static var m_closeCraftingGetGoodsWindowCallback:Function = null;
      
      private static var m_closeCraftingUseGoodsWindowCallback:Function = null;
      
      private static var m_craftingMainWindow:CraftingMainWindow = null;
      
      public function CraftingUI()
      {
         super();
      }
      
      public static function displayMarketStallWindow(marketStallBuilding:MarketStallBuilding, forceRewardsPopup:Boolean = false, onCloseCallback:Function = null, defaultExpandTab:Boolean = false) : void
      {
         m_closeMarketStallWindowCallback = onCloseCallback;
         if(null == m_homeMarketStallWindow)
         {
            m_homeMarketStallWindow = new HomeMarketStallWindow(marketStallBuilding,forceRewardsPopup,defaultExpandTab);
            m_homeMarketStallWindow.addEventListener(CloseEvent.CLOSE,onHomeMarketStallWindowClose);
            UI.displayPopup(m_homeMarketStallWindow,false);
            CraftingManager.getInstance().incrementOpenPopups();
            UI.stopPopups(true);
         }
      }
      
      public static function displayCraftingSiloWindow(craftingSiloBuilding:FeatureBuilding, onCloseCallback:Function = null) : void
      {
         m_closeCraftingSiloWindowCallback = onCloseCallback;
         if(null == m_craftingSiloWindow)
         {
            m_craftingSiloWindow = new CraftingSiloWindow(craftingSiloBuilding);
            m_craftingSiloWindow.addEventListener(CloseEvent.CLOSE,onCraftingSiloWindowClose);
            UI.displayPopup(m_craftingSiloWindow,false);
            CraftingManager.getInstance().incrementOpenPopups();
            UI.stopPopups(true);
         }
      }
      
      private static function onHomeMarketStallWindowClose(event:Event) : void
      {
         if(m_homeMarketStallWindow)
         {
            m_homeMarketStallWindow.removeEventListener(CloseEvent.CLOSE,onHomeMarketStallWindowClose);
            m_homeMarketStallWindow = null;
            CraftingManager.getInstance().decrementOpenPopups();
            if(m_closeMarketStallWindowCallback != null)
            {
               m_closeMarketStallWindowCallback();
               m_closeMarketStallWindowCallback = null;
            }
         }
      }
      
      private static function onCraftingSiloWindowClose(event:Event) : void
      {
         if(m_craftingSiloWindow)
         {
            m_craftingSiloWindow.removeEventListener(CloseEvent.CLOSE,m_closeCraftingSiloWindowCallback);
            m_craftingSiloWindow = null;
            CraftingManager.getInstance().decrementOpenPopups();
            if(m_closeCraftingSiloWindowCallback != null)
            {
               m_closeCraftingSiloWindowCallback();
               m_closeCraftingSiloWindowCallback = null;
            }
         }
      }
      
      public static function displayVisitingMarketStallWindow(uid:String, mode:String, onCloseCallback:Function = null, thankYouFeedBundle:String = "", bushelItemCodeToPresort:String = "") : void
      {
         if(null == m_visitingMarketStallWindow)
         {
            m_visitingMarketStallWindowCloseCallback = onCloseCallback;
            m_visitingMarketStallWindow = new VisitingMarketStallWindow(uid,mode,thankYouFeedBundle,bushelItemCodeToPresort);
            m_visitingMarketStallWindow.addEventListener(CloseEvent.CLOSE,onVisitingMarketStallWindowClose);
            UI.displayPopup(m_visitingMarketStallWindow,false);
            CraftingManager.getInstance().incrementOpenPopups();
            UI.stopPopups(true);
         }
         else
         {
            m_visitingMarketStallWindow.SetThankYouFeedBundle(thankYouFeedBundle);
         }
      }
      
      private static function onVisitingMarketStallWindowClose(event:Event) : void
      {
         if(m_visitingMarketStallWindow)
         {
            m_visitingMarketStallWindow.removeEventListener(CloseEvent.CLOSE,onVisitingMarketStallWindowClose);
            m_visitingMarketStallWindow = null;
            CraftingManager.getInstance().decrementOpenPopups();
            if(m_visitingMarketStallWindowCloseCallback != null)
            {
               m_visitingMarketStallWindowCloseCallback();
               m_visitingMarketStallWindowCloseCallback = null;
            }
         }
      }
      
      public static function closeVisitingMarketStallWindow() : void
      {
         if(m_visitingMarketStallWindow != null)
         {
            m_visitingMarketStallWindow.close();
         }
      }
      
      public static function displaySalesReportWindow(cottage:CraftingCottageBuilding, closeCallback:Function = null) : void
      {
         if(null == m_salesReportWindow)
         {
            m_salesReportWindow = new SalesReportWindow(cottage);
            m_salesReportWindow.addEventListener(CloseEvent.CLOSE,onSalesReportWindowClose);
            m_closeSalesReportWindowCallback = closeCallback;
            UI.displayPopup(m_salesReportWindow,false);
            UI.stopPopups(true);
         }
      }
      
      private static function onSalesReportWindowClose(event:Event) : void
      {
         if(m_salesReportWindow)
         {
            m_salesReportWindow.removeEventListener(CloseEvent.CLOSE,onSalesReportWindowClose);
            m_salesReportWindow = null;
            UI.stopPopups(false);
            if(m_closeSalesReportWindowCallback != null)
            {
               m_closeSalesReportWindowCallback();
               m_closeSalesReportWindowCallback = null;
            }
         }
      }
      
      public static function displayCraftingMySalesWindow(cottage:CraftingCottageBuilding, closeCallback:Function = null) : void
      {
         if(m_craftingMySalesWindow == null)
         {
            m_craftingMySalesWindow = new CraftingMySalesWindow(cottage);
            m_craftingMySalesWindow.addEventListener(CloseEvent.CLOSE,onCraftingMySalesWindowClose);
            m_closeCraftingMySalesWindowCallback = closeCallback;
            UI.displayPopup(m_craftingMySalesWindow,false);
            UI.stopPopups(true);
         }
      }
      
      private static function onCraftingMySalesWindowClose(event:Event) : void
      {
         if(m_craftingMySalesWindow)
         {
            m_craftingMySalesWindow.removeEventListener(CloseEvent.CLOSE,onCraftingMySalesWindowClose);
            m_craftingMySalesWindow = null;
            UI.stopPopups(false);
            if(m_closeCraftingMySalesWindowCallback != null)
            {
               m_closeCraftingMySalesWindowCallback();
               m_closeCraftingMySalesWindowCallback = null;
            }
         }
      }
      
      public static function displayCraftingGetGoodsWindow(closeCallback:Function = null) : void
      {
         if(m_craftingGetGoodsWindow == null)
         {
            m_craftingGetGoodsWindow = new CraftingGetGoodsWindow();
            m_craftingGetGoodsWindow.addEventListener(CloseEvent.CLOSE,onCraftingGetGoodsWindowClose);
            m_closeCraftingGetGoodsWindowCallback = closeCallback;
            UI.displayPopup(m_craftingGetGoodsWindow,false);
            UI.stopPopups(true);
         }
      }
      
      private static function onCraftingGetGoodsWindowClose(event:Event) : void
      {
         if(m_craftingGetGoodsWindow)
         {
            m_craftingGetGoodsWindow.removeEventListener(CloseEvent.CLOSE,onCraftingGetGoodsWindowClose);
            m_craftingGetGoodsWindow = null;
            UI.stopPopups(false);
            if(m_closeCraftingGetGoodsWindowCallback != null)
            {
               m_closeCraftingGetGoodsWindowCallback();
               m_closeCraftingGetGoodsWindowCallback = null;
            }
         }
      }
      
      public static function onMarketViewRefreshed() : void
      {
         if(m_craftingGetGoodsWindow)
         {
            m_craftingGetGoodsWindow.refreshCapacity();
         }
      }
      
      public static function closeCraftingGetGoodsWindow() : void
      {
         if(m_craftingGetGoodsWindow != null)
         {
            m_craftingGetGoodsWindow.close();
         }
      }
      
      public static function displayCraftingUseGoodsWindow(callingPopup:FarmWindow = null, closeCallback:Function = null) : void
      {
         if(m_craftingUseGoodsWindow == null)
         {
            m_craftingUseGoodsWindow = new CraftingUseGoodsWindow(callingPopup);
            m_craftingUseGoodsWindow.addEventListener(CloseEvent.CLOSE,onCraftingUseGoodsWindowClose);
            m_closeCraftingUseGoodsWindowCallback = closeCallback;
            UI.displayPopup(m_craftingUseGoodsWindow,false);
            UI.stopPopups(true);
         }
      }
      
      private static function onCraftingUseGoodsWindowClose(event:Event) : void
      {
         if(m_craftingUseGoodsWindow)
         {
            m_craftingUseGoodsWindow.removeEventListener(CloseEvent.CLOSE,onCraftingUseGoodsWindowClose);
            m_craftingUseGoodsWindow = null;
            UI.stopPopups(false);
            if(m_closeCraftingUseGoodsWindowCallback != null)
            {
               m_closeCraftingUseGoodsWindowCallback();
               m_closeCraftingUseGoodsWindowCallback = null;
            }
         }
      }
      
      public static function closeCraftingUseGoodsWindow() : void
      {
         if(m_craftingUseGoodsWindow != null)
         {
            m_craftingUseGoodsWindow.close();
         }
      }
      
      public static function displayShoppingListWindow(recipe:RecipeItem, closeCallback:Function = null, useShortView:Boolean = false, genericGoods:Boolean = false) : void
      {
         if(!m_shoppingListWindow)
         {
            m_closeShoppingListWindowCallback = closeCallback;
            m_shoppingListWindow = new ShoppingListWindow(recipe,useShortView,genericGoods);
            m_shoppingListWindow.addEventListener(CloseEvent.CLOSE,onShoppingListWindowClose);
            UI.displayPopup(m_shoppingListWindow,false);
            UI.stopPopups(true);
         }
      }
      
      private static function onShoppingListWindowClose(event:Event) : void
      {
         if(m_shoppingListWindow)
         {
            m_shoppingListWindow.removeEventListener(CloseEvent.CLOSE,onShoppingListWindowClose);
            m_shoppingListWindow = null;
            UI.stopPopups(false);
            if(m_closeShoppingListWindowCallback != null)
            {
               m_closeShoppingListWindowCallback();
               m_closeShoppingListWindowCallback = null;
            }
         }
      }
      
      public static function closeShoppingListWindow() : void
      {
         if(m_shoppingListWindow != null)
         {
            m_shoppingListWindow.close();
         }
      }
      
      public static function fuelForGoodsToaster() : void
      {
         var toasterTitle:String = null;
         var toasterMessage:String = null;
         if(Global.player.level >= 15 && (CraftingManager.getInstance().getMarketStallsInWorld().length > 0 || CraftingManager.getInstance().getPlacedCraftingCottages().length > 0) && MarketViewManager.getInstance().getNumFriendsWithCraftedGoodsAvailable() > 0 && !Global.player.getSeenFlag("fuelForGoodsToaster"))
         {
            toasterTitle = ZLocUtils.t("Crafting","Toaster_Title");
            toasterMessage = ZLocUtils.t("Crafting","Toaster_Message");
            ToasterManager.getInstance().add(new IconTitleToasterWindow(toasterTitle,toasterMessage,"assets/hud/fuelCanTall_100x100.png","assets/dialogs/FV_Craft_BannerAd.swf",0.6,new Point(14,11),onToasterMouseClick));
            FarmStatsManager.count("crafting_cottage","buy_goods_toaster","see_toaster");
            Global.player.setSeenFlag("fuelForGoodsToaster");
         }
      }
      
      private static function onToasterMouseClick(event:MouseEvent) : void
      {
         FarmStatsManager.count("crafting_cottage","buy_goods_toaster","click_on_toaster");
         CraftingUI.displayCraftingGetGoodsWindow();
         if(Global.player.level >= 25 && CraftingManager.getInstance().getPlacedCraftingCottages().length == 0 && !Global.player.getSeenSessionFlag("placeCottageReminder"))
         {
            Global.player.setSeenSessionFlag("placeCottageReminder");
            CraftingManager.getInstance().showCottageReminder("buy_goods_toaster",true,false);
         }
      }
      
      public static function getRecipeSlotIcon(craftType:String) : String
      {
         return Global.craftConfigSettings.getCraftingSlotIcon(craftType);
      }
      
      public static function displayCraftingMainWindow(cottageIn:CraftingCottageBuilding, secondaryPopup:int = 0, recipeName:String = "") : void
      {
         if(m_craftingMainWindow == null)
         {
            m_craftingMainWindow = new CraftingMainWindow(cottageIn,secondaryPopup,recipeName);
            m_craftingMainWindow.addEventListener(CloseEvent.CLOSE,onCloseCraftingMainWindow);
            UI.displayPopup(m_craftingMainWindow);
            CraftingManager.getInstance().incrementOpenPopups();
            UI.stopPopups(true);
            displayLEPrompts(cottageIn);
            if(SmartBushelHelper.inExperiment() && SmartBushelHelper.isExpired())
            {
               SmartBushelHelper.smartBushelOffboard();
            }
         }
      }
      
      public static function displayLEPrompts(cottageIn:CraftingCottageBuilding) : void
      {
         var limitedRecipeWindow:LimitedRecipeWindow = null;
         var expiringRecipe:RecipeItem = null;
         var expireRecipeWindow:LimitedRecipeWindow = null;
         var expiredRecipe:RecipeItem = null;
         var recipeIngredient:Object = null;
         var isExpiredBushel:Boolean = false;
         var bushelItem:FarmItem = null;
         var defaultBushel:FarmItem = null;
         var inventoryCount:int = 0;
         var iconDialog:GenericIconPopup = null;
         var expiredSeenFlag:String = null;
         var newRecipes:Array = CraftingManager.getInstance().getNewLimitedRecipes(cottageIn.craftType);
         if(Global.player.getSeenFlag("recipeTut" + CraftingMainWindow.TUTORIAL_LAST_INDEX) && newRecipes.length > 0)
         {
            limitedRecipeWindow = new LimitedRecipeWindow(newRecipes[0],true);
            UI.displayPopup(limitedRecipeWindow,false);
         }
         var expiringRecipes:Array = CraftingManager.getInstance().getExpiringRecipes(cottageIn.craftType);
         if(expiringRecipes.length > 0)
         {
            expiringRecipe = expiringRecipes[0];
            expireRecipeWindow = new LimitedRecipeWindow(expiringRecipe,false);
            UI.displayPopup(expireRecipeWindow,false);
         }
         var expiredRecipes:Array = CraftingManager.getInstance().getExpiredRecipes(cottageIn.craftType);
         if(expiredRecipes.length > 0)
         {
            for each(expiredRecipe in expiredRecipes)
            {
               for each(recipeIngredient in expiredRecipe.ingredients)
               {
                  isExpiredBushel = CraftingManager.getInstance().isBushelExpired(recipeIngredient.itemCode);
                  if(isExpiredBushel)
                  {
                     bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(recipeIngredient.itemCode);
                     defaultBushel = CraftingManager.getInstance().getDefaultExchangeBushel();
                     inventoryCount = CraftingManager.getInstance().getBushelQuantityInInventory(bushelItem.code);
                     if(Boolean(bushelItem) && Boolean(defaultBushel) && int(inventoryCount) > 0)
                     {
                        iconDialog = new GenericIconPopup(ZLocUtils.t("Crafting","LimitedRecipes_Exchange_Prompt",{
                           "quantityA":inventoryCount,
                           "bushelA":ZLocUtils.tk_pk(bushelItem.friendlyName,"",inventoryCount),
                           "quantityB":inventoryCount,
                           "bushelB":ZLocUtils.tk_pk(defaultBushel.friendlyName,"",inventoryCount)
                        }),GenericPopup.TYPE_OK,null,bushelItem.icon,false,true,"",true);
                        UI.displayPopup(iconDialog,false);
                        expiredSeenFlag = CraftingConstants.EXCHANGE_RECIPE_SEEN_FLAG_PREFIX + expiredRecipe.id;
                        Global.player.setSeenFlag(expiredSeenFlag);
                     }
                  }
               }
            }
         }
      }
      
      private static function onCloseCraftingMainWindow(event:Event) : void
      {
         if(m_craftingMainWindow)
         {
            m_craftingMainWindow.removeEventListener(CloseEvent.CLOSE,onCloseCraftingMainWindow);
            m_craftingMainWindow = null;
            CraftingManager.getInstance().decrementOpenPopups();
         }
      }
      
      public static function enterFrame() : void
      {
         if(m_craftingMainWindow)
         {
            m_craftingMainWindow.enterFrame();
         }
         if(m_craftingGetGoodsWindow)
         {
            m_craftingGetGoodsWindow.enterFrame();
         }
         if(m_homeMarketStallWindow)
         {
            m_homeMarketStallWindow.enterFrame();
         }
      }
      
      public static function getCraftingMainWindow() : CraftingMainWindow
      {
         return m_craftingMainWindow;
      }
   }
}

