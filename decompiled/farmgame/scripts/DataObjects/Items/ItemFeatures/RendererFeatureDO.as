package DataObjects.Items.ItemFeatures
{
   public class RendererFeatureDO extends ItemFeatureDO
   {
      
      public var insertionMode:String;
      
      public var itemScale:Number;
      
      public var itemSwf:String;
      
      public var maxItems:int;
      
      public var propPointPrefix:String;
      
      public var propPoints:TilePropPointsDO;
      
      public var renderObject:FeatureRenderObjectDO;
      
      public var textRenderField:FeatureTextRenderFieldDO;
      
      public function RendererFeatureDO()
      {
         super();
      }
   }
}

