package Widgets.Icons
{
   import Classes.util.DisplayObjectUtils;
   import Engine.Managers.LoadingManager;
   import Managers.TemplateUIUtility;
   import Widgets.Core.Icons.ZwAbstractIcon;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.Sprite;
   
   public class FarmIcon extends ZwAbstractIcon
   {
      
      public static const STANDARD_ICON_WIDTH:int = 100;
      
      public static const STANDARD_ICON_HEIGHT:int = 100;
      
      public function FarmIcon(element:DisplayObject, iconUrl:String = null)
      {
         super(element,iconUrl);
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.FARMICON_SMOOTHING))
         {
            this.setSmoothing(true);
         }
         if(Boolean(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.FARMICON)) && Boolean(m_element) && Boolean(m_element["bounds_mc"]))
         {
            this.fitIconInsideBounds(m_element.bounds_mc.width,m_element.bounds_mc.height);
         }
      }
      
      override protected function createLoader(url:String, onLoadCallback:Function) : Loader
      {
         var loadUrl:String = url;
         if(!url.indexOf("http://") == 0 && !url.indexOf("https://") == 0)
         {
            loadUrl = Global.getAssetURL(loadUrl);
         }
         return LoadingManager.load(loadUrl,onLoadCallback);
      }
      
      public function cancelLoad() : void
      {
         if(!m_hasLoaded && Boolean(m_loader))
         {
            LoadingManager.cancelLoad(m_loader);
            m_loader = null;
         }
      }
      
      public function clearScale() : void
      {
         m_scaleX = 1;
         m_scaleY = 1;
      }
      
      public function set applyGrayOut(onOff:Boolean) : void
      {
         var element:Sprite = m_element as Sprite;
         if(element)
         {
            DisplayObjectUtils.grayOut(element,onOff);
         }
      }
   }
}

