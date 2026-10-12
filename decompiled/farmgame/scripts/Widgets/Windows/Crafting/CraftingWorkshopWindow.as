package Widgets.Windows.Crafting
{
   import Classes.FeatureBuilding;
   import Managers.FarmStatsManager;
   import Widgets.Frames.Crafting.ComingSoonPageOneFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class CraftingWorkshopWindow extends FarmWindow
   {
      
      protected var m_building:FeatureBuilding = null;
      
      protected var m_featureName:String = "";
      
      protected var m_firstPageFrame:ComingSoonPageOneFrame = null;
      
      public function CraftingWorkshopWindow(building:FeatureBuilding, featureName:String = "craftingworkshopbuilding")
      {
         this.m_building = building;
         this.m_featureName = featureName;
         super("assets/dialogs/FV_Workshopv1.swf");
      }
      
      override public function close() : void
      {
         FarmStatsManager.count(this.m_building.getItem().name,"level1","x_button");
         super.close();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.m_firstPageFrame = addWidget(new ComingSoonPageOneFrame(m_window.page1_mc,this)) as ComingSoonPageOneFrame;
      }
      
      public function pressOkay(event:MouseEvent) : void
      {
         this.close();
      }
   }
}

