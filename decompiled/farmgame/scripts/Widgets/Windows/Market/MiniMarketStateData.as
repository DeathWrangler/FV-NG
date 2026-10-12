package Widgets.Windows.Market
{
   public class MiniMarketStateData
   {
      
      public var m_itemNames:Array;
      
      public var m_context:String;
      
      public var m_mmType:String;
      
      public var m_closeClickCallBack:Function;
      
      public var m_addToQueue:Boolean;
      
      public var m_showLimitedItems:Boolean;
      
      public var m_hideCloseButton:Boolean;
      
      public var m_checkVisible:Boolean;
      
      public var m_featureName:String;
      
      public function MiniMarketStateData(itemNames:Array, viewSource:String = "unknown", type:String = "seed", closeClickCallback:Function = null, addToQueue:Boolean = true, showLimitedItems:Boolean = false, hideCloseButton:Boolean = false, checkVisible:Boolean = false, featureName:String = "")
      {
         super();
         this.m_itemNames = itemNames;
         this.m_context = viewSource;
         this.m_mmType = type;
         this.m_closeClickCallBack = closeClickCallback;
         this.m_addToQueue = addToQueue;
         this.m_showLimitedItems = showLimitedItems;
         this.m_hideCloseButton = hideCloseButton;
         this.m_checkVisible = checkVisible;
         this.m_featureName = featureName;
      }
   }
}

