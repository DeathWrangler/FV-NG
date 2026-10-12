package Widgets.Windows.MOTD
{
   import Cache.Classes.ZCacheCapabilities;
   import Cache.Interfaces.IZCache;
   import Classes.util.FarmGameUtil;
   import Widgets.Buttons.FarmAnimatedButton;
   import flash.events.MouseEvent;
   
   public class FastFarmTravelMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_FastFarmTravel_MOTD.swf";
      
      private var m_isZCacheEnableOptionAvailable:Boolean = false;
      
      public function FastFarmTravelMOTDWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var zCache:IZCache = GlobalZCache.instance;
         var isCompatible:Boolean = ZCacheCapabilities.isZCacheCompatible();
         this.m_isZCacheEnableOptionAvailable = Boolean(zCache) && !zCache.allowed && isCompatible;
         if(m_window.zCache_mc)
         {
            m_window.zCache_mc.visible = this.m_isZCacheEnableOptionAvailable;
         }
         if(m_window.okay_bt)
         {
            addWidget(new FarmAnimatedButton(m_window.okay_bt,this.onClickOkay));
         }
      }
      
      private function onClickOkay(event:MouseEvent) : void
      {
         if(this.m_isZCacheEnableOptionAvailable)
         {
            FarmGameUtil.showZCachePermissionsPrompt();
         }
         super.onClose(event);
      }
   }
}

