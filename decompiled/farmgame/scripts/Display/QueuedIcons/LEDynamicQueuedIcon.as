package Display.QueuedIcons
{
   import Classes.Animal;
   import Classes.ZItem.FarmItem;
   import Managers.LESurfacingManager;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class LEDynamicQueuedIcon extends DynamicContentQueuedIcon
   {
      
      public static const LE_DYNAMIC_ICON_TYPE:String = "LEDynamicIcon";
      
      private static const ICON_SIZE:int = 100;
      
      private var m_lootItems:Array;
      
      private var m_assetLoaded:Boolean = false;
      
      public function LEDynamicQueuedIcon(xml:XML)
      {
         super(xml);
      }
      
      override protected function onButtonIconLoaded(event:Event) : void
      {
         this.m_assetLoaded = true;
         this.m_lootItems = LESurfacingManager.instance.LEWindowItems;
         if(this.m_lootItems == null)
         {
            LESurfacingManager.instance.setLEWindowItems();
         }
         super.onButtonIconLoaded(event);
      }
      
      override protected function injectContent() : void
      {
         var loadedMC:MovieClip = null;
         var randomNum:int = 0;
         var selectedType:String = null;
         var selectedItem:FarmItem = null;
         var index:int = 0;
         var item:FarmItem = null;
         var offset:Point = null;
         var m_objectPreviewFrame:ObjectPreviewFrame = null;
         var farmIcon:FarmIcon = null;
         if(this.m_assetLoaded && this.m_lootItems != null && this.m_lootItems.length > 0)
         {
            loadedMC = m_Loader.content as MovieClip;
            randomNum = Math.floor(Math.random() * 100) % 2;
            selectedType = "";
            selectedType = randomNum == 0 ? "animal" : "tree";
            selectedItem = this.m_lootItems[0] as FarmItem;
            for(index = 0; index < this.m_lootItems.length; index++)
            {
               item = this.m_lootItems[index] as FarmItem;
               if(item.type == selectedType)
               {
                  selectedItem = item;
                  break;
               }
            }
            if(selectedItem != null)
            {
               if(selectedItem.type == "animal")
               {
                  offset = new Point(0,0);
                  m_objectPreviewFrame = new ObjectPreviewFrame(loadedMC.item_mc,selectedItem,null,[selectedItem.sizeX == 1 ? 2 : 1.75],null,Animal.STATE_FRONT_IDLE,"",null,offset);
                  (m_objectPreviewFrame.element as MovieClip).filters = [];
                  m_widgetManager.addWidget(m_objectPreviewFrame,true);
               }
               else
               {
                  farmIcon = new FarmIcon(loadedMC.item_mc);
                  farmIcon.loadIcon(selectedItem.icon);
                  farmIcon.setIconSize(ICON_SIZE,ICON_SIZE);
                  m_widgetManager.addWidget(farmIcon);
               }
            }
         }
      }
   }
}

