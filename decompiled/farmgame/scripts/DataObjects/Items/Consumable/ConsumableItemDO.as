package DataObjects.Items.Consumable
{
   import DataObjects.Items.BaseItemDO;
   
   public class ConsumableItemDO extends BaseItemDO
   {
      
      [XmlAttribute(§default§="true")]
      public var getFromMarket:Boolean;
      
      [XmlAttribute]
      public var useOnBuy:Boolean;
      
      public var coins:int;
      
      public var craftingSystem:String;
      
      public var defaultPrice:int;
      
      public var featureName:String;
      
      public var gameToken:String;
      
      public var harvestCount:int;
      
      public var harvestType:String;
      
      public var minPercent:Number;
      
      public var minPlots:int;
      
      public var railsPriceMax:int;
      
      public var railsPriceMin:int;
      
      public var rewardGift:String;
      
      public var seed:String;
      
      public var toasterOnConsume:ItemToasterOnConsumeDO;
      
      public var xp:int;
      
      public var dragonCode:String;
      
      public var plantTimeRatio:Number;
      
      public var masteryBonus:Number;
      
      public var bushelMultiplier:Number;
      
      public function ConsumableItemDO()
      {
         super();
      }
   }
}

