package Widgets.Windows.Crafting
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.ChooseCottageDetailFrame;
   import Widgets.Frames.Crafting.ChooseCottageOverviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   
   public class ChooseCottageWindow extends FarmWindow
   {
      
      public function ChooseCottageWindow()
      {
         super("assets/dialogs/FV_Craft_NewFeature_Choose.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new FarmIcon(m_window.goldBar_mc),false);
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Crafting","ChooseCraft_Title")),false);
         addWidget(new ChooseCottageOverviewFrame(m_window.overViewFrame_mc,this));
         addWidget(new ChooseCottageDetailFrame(m_window.detailFrame_mc,this),false);
      }
      
      public function showCraftDetailFrame(craftType:String) : void
      {
         var detailFrame:ChooseCottageDetailFrame = getWidget(m_window.detailFrame_mc) as ChooseCottageDetailFrame;
         detailFrame.setCraftType(craftType);
         detailFrame.visible = true;
         var overviewFrame:ChooseCottageOverviewFrame = getWidget(m_window.overViewFrame_mc) as ChooseCottageOverviewFrame;
         overviewFrame.visible = false;
         this.showTitleBar(true);
      }
      
      public function showOverviewFrame() : void
      {
         var detailFrame:ChooseCottageDetailFrame = getWidget(m_window.detailFrame_mc) as ChooseCottageDetailFrame;
         detailFrame.visible = false;
         var overviewFrame:ChooseCottageOverviewFrame = getWidget(m_window.overViewFrame_mc) as ChooseCottageOverviewFrame;
         overviewFrame.visible = true;
         this.showTitleBar(false);
      }
      
      private function showTitleBar(show:Boolean) : void
      {
         var title:ZwTextField = getWidget(m_window.title_tf) as ZwTextField;
         if(title)
         {
            title.visible = show;
         }
         var goldBar:FarmIcon = getWidget(m_window.goldBar_mc) as FarmIcon;
         if(goldBar)
         {
            goldBar.visible = show;
         }
      }
   }
}

