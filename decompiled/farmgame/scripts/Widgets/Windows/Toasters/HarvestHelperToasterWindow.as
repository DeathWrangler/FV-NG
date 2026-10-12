package Widgets.Windows.Toasters
{
   import Classes.buffs.BHarvestHelper;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.ToasterWindow;
   
   public class HarvestHelperToasterWindow extends ToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_HarvestHelper2014_Toaster.swf";
      
      private var m_callback:Function = null;
      
      private var m_animationStartX:Number;
      
      private var m_animationStartY:Number;
      
      private var m_harvestHelperIcon:ZwWidget;
      
      public function HarvestHelperToasterWindow(callback:Function)
      {
         this.m_callback = callback;
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("generic_desc_tf"))
         {
            addWidget(new FarmTextField(m_window.generic_desc_tf,ZLocUtils.t("Dialogs","Harvest_Helper_Body",{"multiplier":BHarvestHelper.MULTIPLIER_VALUE.toString()})));
         }
         if(m_window.hasOwnProperty("generic_tf"))
         {
            addWidget(new FarmTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","Harvest_Helper_Title")));
         }
         if(m_window.hasOwnProperty("hh_icon"))
         {
            addWidget(this.m_harvestHelperIcon = new ZwWidget(m_window.hh_icon));
         }
         FarmStatsManager.count("view","harvestHelperToaster");
      }
      
      override protected function getToasterHeight() : Number
      {
         return m_window.height / 2;
      }
      
      override protected function hideTween(callback:Function) : void
      {
         if(this.m_callback != null)
         {
            this.m_animationStartX = this.x + this.m_harvestHelperIcon.x;
            this.m_animationStartY = this.y - this.getToasterHeight() + this.m_harvestHelperIcon.y;
            this.m_callback(this.m_animationStartX,this.m_animationStartY);
         }
         super.hideTween(callback);
         FarmStatsManager.count("close","harvestHelperToaster");
      }
   }
}

