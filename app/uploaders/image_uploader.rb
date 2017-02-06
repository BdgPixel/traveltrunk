# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  process :resize_to_fill => [225, 225]

  version :thumb do
    resize_to_fill(17, 17, 'North')
  end

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    ActionController::Base.helpers.asset_path([version_name, "default_user.png"].compact.join('_'))
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def auto_orient
    manipulate! do |img|
      img.tap(&:auto_orient)
    end
  end

  process :auto_orient
end
