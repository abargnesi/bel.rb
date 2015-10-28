require 'bel'

include BEL::Model

describe 'BEL Extensions' do

  it 'users can find all available extensions' do

    extensions = BEL::Extension.all.to_a
  end

  it 'users can find extension(s) by id' do

    id = 'bel'
    extensions = BEL::Extension.all.select { |ext|
      ext.id == id
    }
  end

  it 'users can find a translator extension by id' do

    id = 'bel'
    extension = BEL::Extension.translators.find { |ext|
      ext.id == id
    }
  end

  it 'users can find an rdf repository extension by id' do

    id = 'rdf_mongo'
    extension = BEL::Extension.rdf_repositories.find { |ext|
      ext.id == id
    }
  end
end

# vim: ts=2 sw=2
# encoding: utf-8
