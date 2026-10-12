package DataObjects.Items.CoreItems
{
   import DataObjects.Items.BaseItemDO;
   
   public class CoreItemDO extends BaseItemDO
   {
      
      [XmlAttribute(§default§="true")]
      public var canSellFromGiftBox:Boolean;
      
      [XmlAttribute]
      public var cat:Boolean;
      
      [XmlAttribute]
      public var colorGroup:String;
      
      [XmlAttribute]
      public var dialogName:String;
      
      [XmlAttribute]
      public var fvdotcomonly:Boolean;
      
      [XmlAttribute]
      public var ignorePetHarvest:Boolean;
      
      [XmlAttribute]
      public var mastery:Boolean;
      
      [XmlAttribute]
      public var popupType:String;
      
      [XmlAttribute]
      public var preview:String;
      
      [XmlAttribute]
      public var promoMode:String;
      
      [XmlAttribute]
      public var subsubtype:String;
      
      public var actionText:String;
      
      public var aoeTargetKeyword:String;
      
      public var eventCallbackName:String;
      
      public var assetKey:String;
      
      public var basket:String;
      
      public var breedingShare:String;
      
      public var depthOffset:ItemDepthOffsetDO;
      
      public var disallowDelete:int;
      
      public var disallowMove:int;
      
      public var friendReward:String;
      
      public var friendRewardType:String;
      
      public var fullLootTable:String;
      
      public var gameSettingsFeatureName:String;
      
      public var geoip:ItemGeoIPDO;
      
      public var giftSelection:ItemGiftSelectionDO;
      
      public var highlightColor:String;
      
      public var insanityProbability:Number;
      
      public var limitType:String;
      
      public var masteryYield:int;
      
      public var partyReference:String;
      
      public var presents:int;
      
      public var subcreditsType:String;
      
      public var tag:String;
      
      public var tooltipKey:String;
      
      public var tooltipKeyNew:String;
      
      public var toolTipOffset:ItemToolTipOffsetDO;
      
      public var altGraphic:Array;
      
      public var harvestYield:Array;
      
      public var masteryLevel:Array;
      
      public var rewardGift:Array;
      
      public function CoreItemDO()
      {
         super();
      }
   }
}

