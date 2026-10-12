package Widgets.Windows.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingStation;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Display.UI;
   import Managers.TemplateUIUtility;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingRecipeSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   
   public class FeatureCraftingRecipesWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_station:FeatureCraftingStation;
      
      private var m_closeCallback:Function;
      
      private var m_recipeSlots:FeatureCraftingRecipeSlotContainerFrame;
      
      private var m_icon:FarmIcon;
      
      private var m_location:String = this.m_station.system.location;
      
      public function FeatureCraftingRecipesWindow(station:FeatureCraftingStation, closeCallback:Function = null)
      {
         this.m_station = station;
         this.m_closeCallback = closeCallback;
         super(this.m_station.system.getAssetUrl(FeatureCraftingSystem.ASSET_DIALOG_RECIPE));
      }
      
      public static function display(station:FeatureCraftingStation, closeCallback:Function = null) : FeatureCraftingRecipesWindow
      {
         var window:FeatureCraftingRecipesWindow = null;
         if(station)
         {
            window = new FeatureCraftingRecipesWindow(station,closeCallback);
            UI.displayPopup(window,false,"FeatureCraftingRecipesWindow",true);
         }
         return window;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,this.m_station.friendlyTitle)) as ZwTextField;
         if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_window.title_tf);
         }
         if(m_window.hasOwnProperty("stationicon_mc"))
         {
            this.m_icon = addWidget(new FarmIcon(m_window.stationicon_mc)) as FarmIcon;
            this.m_icon.clearScale();
            this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
            this.m_icon.setSmoothing(true);
         }
         this.m_recipeSlots = addWidget(new FeatureCraftingRecipeSlotContainerFrame(m_window.recipes_mc)) as FeatureCraftingRecipeSlotContainerFrame;
         if(m_window.recipes_mc.page_tf)
         {
            if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.recipes_mc.page_tf);
            }
         }
         this.refresh();
      }
      
      override protected function release() : void
      {
         this.m_station = null;
         this.m_closeCallback = null;
         this.m_recipeSlots = null;
         this.m_icon = null;
         super.release();
      }
      
      public function get station() : FeatureCraftingStation
      {
         return this.m_station;
      }
      
      public function refresh() : void
      {
         var recipes:Array = null;
         if(m_window)
         {
            recipes = this.m_station.system.getRecipesGivenRecipeNames(this.m_station.getAllRecipeNames());
            recipes = recipes.concat();
            recipes.sortOn(["hasAllRequiredGoods","unlockLevel"],[Array.DESCENDING,Array.NUMERIC]);
            this.m_recipeSlots.items = recipes;
            if(this.m_icon)
            {
               this.m_icon.loadIcon(this.m_station.iconUrl);
               this.m_icon.visible = true;
            }
         }
      }
      
      public function startRecipe(recipeName:String) : void
      {
         if(Boolean(m_window) && Boolean(this.m_station))
         {
            this.m_station.startRecipe(recipeName);
            if(this.m_closeCallback != null)
            {
               this.m_closeCallback(true);
            }
            close();
         }
      }
   }
}

