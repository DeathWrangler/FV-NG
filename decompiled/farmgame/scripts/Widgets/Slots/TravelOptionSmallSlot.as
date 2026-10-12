package Widgets.Slots
{
   import Classes.util.ObjectUtil;
   import Managers.WorldManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class TravelOptionSmallSlot extends ZwSlotFrame
   {
      
      private static const ICON_WIDTH_SIZE:int = 217;
      
      private static const ICON_HEIGHT_SIZE:int = 169;
      
      private var m_data:Object;
      
      private var m_icon:FarmIcon;
      
      private var m_clickCallback:Function;
      
      public function TravelOptionSmallSlot(element:DisplayObject, clickCallback:Function)
      {
         super(element);
         this.m_clickCallback = clickCallback;
         addWidget(new FarmAnimatedButton(m_element as MovieClip,this.onTravelCallBack)) as FarmAnimatedButton;
         if(ObjectUtil.pathExists(m_element,"image_mc"))
         {
            this.m_icon = addWidget(new FarmIcon(m_element.image_mc)) as FarmIcon;
            this.m_icon.setIconSize(ICON_WIDTH_SIZE,ICON_HEIGHT_SIZE);
         }
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      override public function populate(data:Object) : void
      {
         var smallIconType:String = null;
         var assetUrl:String = null;
         super.populate(data);
         this.m_data = data;
         if(this.m_data != null)
         {
            smallIconType = WorldSeasonsManager.getInstance().getCurrentSeason(this.m_data.toString()) == WorldSeasonsManager.SEASON_TWO ? WorldManager.FASTTRAVELSMALLICON2 : WorldManager.FASTTRAVELSMALLICON;
            assetUrl = Global.worldManager.getWorldTravelAssetUrl(this.m_data.toString(),smallIconType);
            if(assetUrl != null)
            {
               this.m_icon.loadIcon(assetUrl);
               this.m_icon.visible = true;
            }
         }
      }
      
      private function onTravelCallBack(event:Event) : void
      {
         if(this.m_clickCallback != null)
         {
            this.m_clickCallback(this.m_data);
         }
      }
   }
}

