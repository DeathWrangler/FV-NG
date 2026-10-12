package Widgets.Icons
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Util.ZwWidgetUtils;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class FarmItemIcon
   {
      
      protected var m_iconMc:FarmIcon = null;
      
      private var m_objectPreviewFrame:ObjectPreviewFrame;
      
      private var m_isAnimatedSlot:Boolean = true;
      
      private var m_element:MovieClip = null;
      
      private var m_parentWidget:ZwFrame = null;
      
      private var m_framePosition:Point = new Point();
      
      private var m_frameDimensions:Point = new Point();
      
      public function FarmItemIcon(parentWidget:ZwFrame, element:MovieClip, item:FarmItem = null, animatedIfPossible:Boolean = true)
      {
         super();
         this.m_isAnimatedSlot = animatedIfPossible;
         this.m_element = element;
         this.m_parentWidget = parentWidget;
         this.m_framePosition = new Point(element.x,element.y);
         this.m_frameDimensions = new Point(element.width,element.height);
         if(element != null)
         {
            ZwWidgetUtils.removeAllChildren(element);
         }
         if(item != null)
         {
            this.reloadItem(item,animatedIfPossible);
         }
         else
         {
            this.m_iconMc = this.m_parentWidget.addWidget(new FarmIcon(this.m_element)) as FarmIcon;
         }
      }
      
      public function get element() : MovieClip
      {
         return this.m_element;
      }
      
      public function reloadItem(item:FarmItem, animatedIfPossible:Boolean = true) : void
      {
         var itemName:String = null;
         var sizeScale:Number = NaN;
         if(item != null && this.m_element != null && this.m_parentWidget != null)
         {
            this.m_isAnimatedSlot = animatedIfPossible;
            this.releaseMCs();
            itemName = item.name;
            if(Boolean(this.m_isAnimatedSlot == true && item != null) && Boolean(this.m_element) && item.getImageByName("frt_idle") != null)
            {
               sizeScale = Math.min(2,7 / (item.sizeX + item.sizeY) / item.imageScale);
               this.m_objectPreviewFrame = new ObjectPreviewFrame(this.m_element,item,null,[sizeScale],null,"frt_idle");
               (this.m_objectPreviewFrame.element as MovieClip).filters = [];
               this.m_objectPreviewFrame.x = this.m_framePosition.x + this.m_frameDimensions.x / 2;
               this.m_objectPreviewFrame.y = this.m_framePosition.y + this.m_frameDimensions.y / 2;
               this.m_parentWidget.addWidget(this.m_objectPreviewFrame,true);
            }
            else
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               this.loadAsIcon(item.iconRelativeUrl);
            }
         }
      }
      
      public function releaseMCs() : void
      {
         if(this.m_objectPreviewFrame != null)
         {
            this.m_parentWidget.removeWidget(this.m_objectPreviewFrame);
            this.m_objectPreviewFrame = null;
         }
         if(this.m_iconMc != null)
         {
            this.m_parentWidget.removeWidget(this.m_iconMc);
            this.m_iconMc = null;
         }
      }
      
      private function loadAsIcon(relativeUrl:String) : void
      {
         if(this.m_iconMc == null)
         {
            this.m_iconMc = this.m_parentWidget.addWidget(new FarmIcon(this.m_element)) as FarmIcon;
         }
         if(this.m_iconMc != null && relativeUrl != "")
         {
            this.m_iconMc.loadIcon(relativeUrl,function():void
            {
               if(m_iconMc != null && m_iconMc.element != null)
               {
                  m_iconMc.x = m_framePosition.x;
                  m_iconMc.y = m_framePosition.y;
               }
            });
            this.m_iconMc.visible = true;
         }
      }
      
      public function loadIconUrl(relativeUrl:String) : void
      {
         this.releaseMCs();
         this.loadAsIcon(relativeUrl);
      }
      
      public function getActiveWidget() : ZwWidget
      {
         if(this.m_iconMc != null)
         {
            return this.m_iconMc;
         }
         return this.m_objectPreviewFrame;
      }
   }
}

