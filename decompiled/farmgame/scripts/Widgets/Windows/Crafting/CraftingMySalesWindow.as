package Widgets.Windows.Crafting
{
   import Classes.CraftingCottageBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.CraftingStoreFrontFrame;
   import Widgets.Windows.FarmWindow;
   
   public class CraftingMySalesWindow extends FarmWindow
   {
      
      private var m_cottage:CraftingCottageBuilding = null;
      
      public function CraftingMySalesWindow(cottage:CraftingCottageBuilding)
      {
         super("assets/dialogs/FV_Craft_MySales.swf");
         this.m_cottage = cottage;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Crafting","CraftingMain_MySales")));
         addWidget(new CraftingStoreFrontFrame(m_window.storeFrontFrame_mc,this.m_cottage.finishedRecipeMarketInventoryItems,null,this.m_cottage));
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_cottage = null;
      }
   }
}

