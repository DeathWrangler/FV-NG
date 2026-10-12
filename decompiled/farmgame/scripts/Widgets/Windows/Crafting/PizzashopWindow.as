package Widgets.Windows.Crafting
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   
   public class PizzashopWindow extends CraftshopWindow
   {
      
      public static const PIZZASHOP_BUILDING:String = "pizzashopbuilding";
      
      private var m_fastExpandDialog:GenericPopup;
      
      public function PizzashopWindow(building:FeatureBuilding, featureName:String = "pizzashopbuilding")
      {
         super(building,featureName);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.showExpandFrame(false);
      }
      
      override protected function getDialogAsset() : String
      {
         return m_building.getFarmItem().getDialogConfig("storage").path;
      }
      
      override public function canMakeRecipeInThisWorld(recipeItem:RecipeItem = null) : int
      {
         var result:int = CraftingConstants.CAN_MAKE_RECIPE;
         if(super.canMakeRecipeInThisWorld() != CraftingConstants.CAN_MAKE_RECIPE)
         {
            result = CraftingConstants.OVEN_SLOTS_FULL;
         }
         else if(recipeItem.isRecursiveRecipe() && !CraftingManager.canMakeRecursiveRecipe(recipeItem))
         {
            result = CraftingConstants.MAX_BUSHEL_CAPACITY;
         }
         return result;
      }
      
      override public function makeRecipe(recipeId:String) : void
      {
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         var ovenSlot:int = nextAvailableOvenSlot;
         if(Boolean(recipeItem) && ovenSlot >= 0)
         {
            pause();
            recipeItem.ovenSlot = ovenSlot;
            recipeItem.worldType = Global.worldManager.currentWorldType;
            CraftingManager.getInstance().beginRecipe(recipeItem,onRecipeBeginDone);
         }
      }
      
      override public function update() : void
      {
         if(m_searchFrame)
         {
            m_searchFrame.update();
         }
         m_ovenFrame.update();
         m_recipeFrame.update();
      }
      
      public function onAcceptExpand(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            m_building.frictionlessExpand();
            this.update();
         }
      }
      
      override public function showExpandFrame(showPanel:Boolean) : void
      {
         var parts:Array = null;
         var part:FarmItem = null;
         super.showExpandFrame(false);
         if(showPanel)
         {
            parts = m_building.getPartsArray();
            if(parts.length > 0)
            {
               part = Global.farmGameSettingsManager.getFarmItemByName(parts[0]);
               if(part != null && Boolean(part.cash))
               {
                  this.m_fastExpandDialog = new GenericPopup(ZLocUtils.t("Dialogs",m_building.getItem().craftType + "InstantExpand",{"price":part.cash}),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptExpand);
                  UI.displayPopup(this.m_fastExpandDialog,false,"",false);
               }
            }
         }
         else if(this.m_fastExpandDialog)
         {
            this.m_fastExpandDialog.close();
         }
      }
   }
}

