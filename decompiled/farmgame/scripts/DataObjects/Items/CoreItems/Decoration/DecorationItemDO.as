package DataObjects.Items.CoreItems.Decoration
{
   import DataObjects.Items.CoreItems.CoreItemDO;
   
   public class DecorationItemDO extends CoreItemDO
   {
      
      [XmlAttribute(§default§="true")]
      public var allowUserToggleAltGraphic:Boolean;
      
      [XmlAttribute]
      public var bypassLimitedEndForBuy:Boolean;
      
      [XmlAttribute(§default§="true")]
      public var deletable:Boolean;
      
      [XmlAttribute]
      public var dialogClass:String;
      
      [XmlAttribute]
      public var expendable:Boolean;
      
      [XmlAttribute]
      public var fence:Boolean;
      
      [XmlAttribute]
      public var generateRewardFeed:Boolean;
      
      [XmlAttribute]
      public var golden:Boolean;
      
      [XmlAttribute(§default§="-2147483648")]
      public var harvestProbablity:Number;
      
      [XmlAttribute]
      public var isGameToken:Boolean;
      
      [XmlAttribute]
      public var isGift:Boolean;
      
      [XmlAttribute]
      public var newUser:Boolean;
      
      [XmlAttribute]
      public var noMysteryAchievement:Boolean;
      
      [XmlAttribute]
      public var shareItem:String;
      
      public var featureName:String;
      
      [XmlAttribute]
      public var showFreeGiftBorder:Boolean;
      
      [XmlAttribute]
      public var specialValentinesItem:Boolean;
      
      [XmlAttribute]
      public var statsType:String;
      
      [XmlAttribute]
      public var thankyougift:Boolean;
      
      public var activeFrame:int;
      
      public var autoActivateDate:String;
      
      public var autoDeactivateDate:String;
      
      public var creditName:String;
      
      public var disallowStore:int;
      
      public var forcedGiftTable:String;
      
      public var freeGiftTitle:String;
      
      public var giftPageRotation:String;
      
      public var harvestSources:ItemHarvestSourcesDO;
      
      public var liveTime:int;
      
      public var masteredItemCode:String;
      
      public var maxPercentXp:int;
      
      public var maxUserAge:int;
      
      public var maxWait:int;
      
      public var minUserAge:int;
      
      public var minWait:int;
      
      public var minXp:int;
      
      public var moreInfoURL:String;
      
      public var openEnd:String;
      
      public var openStart:String;
      
      public var partDisplacements:ItemPartDisplacementsDO;
      
      public var partSizes:ItemPartSizesDO;
      
      public var superItemCode:String;
      
      public var swapCountdown:ItemSwapCountdownDO;
      
      public var stencilWidth:Number;
      
      public var stencilHeight:Number;
      
      public var collision:Array;
      
      public var gem:Array;
      
      public var metal:Array;
      
      public function DecorationItemDO()
      {
         super();
      }
   }
}

