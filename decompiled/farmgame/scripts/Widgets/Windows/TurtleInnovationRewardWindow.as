package Widgets.Windows
{
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.FarmItem;
   import Classes.feed.GenericRewardFeed;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class TurtleInnovationRewardWindow extends FarmWindow
   {
      
      public static const ZOOM_LEVELS:Array = new Array(2,1.434,0.868,0.585);
      
      public static const ZOOM_WIDTHS:Array = new Array(260,300,320,330);
      
      protected var m_featureName:String;
      
      protected var m_itemName:String;
      
      protected var m_bundleName:String;
      
      public function TurtleInnovationRewardWindow(featureName:String, itemName:String, bundleName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         this.m_itemName = itemName;
         this.m_bundleName = bundleName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var icon:FarmIcon = null;
         super.postLoadComplete();
         var item:FarmItem = null;
         var bonusItem:FarmItem = null;
         if(this.m_itemName)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         }
         if(m_window.hasOwnProperty("generic_tf"))
         {
            addWidget(new FarmTextField(m_window["generic_tf"],"Congrats!"));
         }
         if(m_window.hasOwnProperty("generic2_tf") && Boolean(item))
         {
            addWidget(new FarmTextField(m_window["generic2_tf"],"You\'ve got a " + item.friendlyTitle + "!"));
         }
         if(m_window.hasOwnProperty("generic3_tf"))
         {
            addWidget(new FarmTextField(m_window["generic3_tf"],"Subtext"),false);
         }
         if(m_window.hasOwnProperty("icon_mc") && Boolean(item))
         {
            if(item is ConsumableItem)
            {
               icon = new FarmIcon(m_window.icon_mc,item.imageRelativeUrl("feed"));
               icon.setIconHeight(200);
               icon.setIconWidth(200);
               addWidget(icon);
            }
            else
            {
               addWidget(new ObjectPreviewFrame(m_window["icon_mc"],item,null,null,[200]));
            }
         }
         if(bonusItem)
         {
            if(m_window.hasOwnProperty("bonus_mc"))
            {
               (m_window.bonus_mc as MovieClip).visible = true;
               if(m_window.bonus_mc["bonusicon_mc"])
               {
                  addWidget(new ObjectPreviewFrame(m_window.bonus_mc["bonusicon_mc"],bonusItem,null,null,[120]));
               }
               if(m_window.bonus_mc["name_tf"])
               {
                  addWidget(new FarmTextField(m_window.bonus_mc["name_tf"],bonusItem.friendlyTitle));
               }
            }
         }
         else if(m_window.hasOwnProperty("giftbox_mc"))
         {
            (m_window.giftbox_mc as MovieClip).visible = true;
         }
         if(m_window.hasOwnProperty("share_bt") && Boolean(this.m_bundleName))
         {
            addWidget(new FarmAnimatedTextButton(m_window["share_bt"],"Share!",this.onButtonClick));
         }
      }
      
      private function onButtonClick(event:Event) : void
      {
         var _item:String = this.m_itemName;
         if(_item)
         {
            new GenericRewardFeed(_item,this.m_bundleName).shareFeed();
         }
         this.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
   }
}

