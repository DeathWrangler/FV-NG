package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LightningDealsViewBundleFrame;
   
   public class LightningDealsViewBundle extends FarmWindow
   {
      
      private var m_bundleItem:FarmItem;
      
      public function LightningDealsViewBundle(bundleItem:FarmItem)
      {
         this.m_bundleItem = bundleItem;
         super("assets/dialogs/LightningDeals2017/FV_LightningDeals2017_View.swf",true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window["title_tf"],this.m_bundleItem.friendlyTitle),true);
         addWidget(new LightningDealsViewBundleFrame(m_window["slots_mc"],"",this.m_bundleItem),true);
      }
   }
}

